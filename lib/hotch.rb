require 'stackprof'
require 'tmpdir'

require 'hotch/version'

class Hotch
  attr_reader :name, :viewer, :filter, :options

  def initialize(name, viewer: nil, filter: nil, options: {})
    @name = name
    @viewer = viewer
    @options = options
    @reports = []

    @options[:filter] = Regexp.new(filter) if filter
  end

  def start(...)
    StackProf.start(...) unless StackProf.running?
  end

  def stop
    if StackProf.running?
      StackProf.stop
      @reports << StackProf::Report.new(results)
    end
  end

  def run(...)
    start(...)
    yield
  ensure
    stop
  end

  def results
    StackProf.results
  end

  def report
    report = @reports.inject(:+) or return

    dir = Dir.mktmpdir("hotch.#{name}.")

    report_dump(report, dir, "profile.dump")
    dot = report_dot(report, dir, "profile.dot")
    svg = convert_svg(dir, dot, "profile.svg")

    @reports.clear

    if block_given?
      yield report, svg
    else
      return report, svg
    end
  end

  def report_at_exit
    return if defined? @at_exit_installed

    at_exit do
      stop

      report do |_, svg|
        if viewer
          puts "Profile SVG: #{svg}"
          Kernel.system viewer, svg
        else
          puts "Profile SVG: view #{svg} # no HOTCH_VIEWER set"
        end
      end
    end

    @at_exit_installed = true
  end

  private

  def name
    @name.gsub(/\W+/, '_')
  end

  def report_dump(report, dir, file)
    write_file(dir, file) do |fh|
      report.print_dump(fh)
    end
  end

  def report_dot(report, dir, file)
    write_file(dir, file) do |fh|
      report.print_graphviz(options, fh)
    end
  end

  def convert_svg(dir, dot, file)
    svg = File.join(dir, file)
    system("dot", "-Tsvg", "-o", svg, dot) or raise "dot: command not found. Please install graphviz"
    svg
  end

  def write_file(dir, file)
    path = File.join(dir, file)
    File.open(path, 'wb') do |fh|
      yield fh
    end
    path
  end
end

def Hotch(name: $0, aggregate: true, viewer: ENV['HOTCH_VIEWER'], filter: ENV['HOTCH_FILTER'], options: {})
  hotch = if aggregate
    $hotch ||= Hotch.new(name, viewer: viewer, filter: filter, options: options)
  else
    caller = Kernel.caller_locations(1).first
    name = "#{name}:#{caller.path}:#{caller.lineno}"
    Hotch.new(name, viewer: viewer, filter: filter, options: options)
  end

  hotch.report_at_exit
  hotch.run do
    yield
  end
end
