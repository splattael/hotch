require 'stackprof'
require 'tmpdir'

require 'hotch/monkey_patches'

class Hotch
  attr_reader :name, :viewer, :filter

  def initialize(name, viewer: nil, filter: nil)
    @name = name
    @viewer = viewer
    @filter = filter
    @reports = []
  end

  def start(*args)
    StackProf.start(*args) unless StackProf.running?
  end

  def stop
    if StackProf.running?
      StackProf.stop
      @reports << StackProf::Report.new(results)
    end
  end

  def run(*args)
    start(*args)
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

    yield svg
  end

  def report_at_exit
    return if defined? @at_exit_installed

    at_exit do
      stop

      report do |svg|
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
    path = File.join(dir, file)
    File.open(path, 'wb') do |fh|
      report.print_dump(fh)
    end
    path
  end

  def report_dot(report, dir, file)
    path = File.join(dir, file)
    File.open(path, 'wb') do |fh|
      report.print_graphviz(filter && Regexp.new(filter), fh)
    end
    path
  end

  def convert_svg(dir, dot, file)
    svg = File.join(dir, file)
    system("dot", "-Tsvg", "-o", svg, dot) or raise "dot failed"
    svg
  end
end

def Hotch(name: $0, aggregate: true, viewer: ENV['HOTCH_VIEWER'], filter: ENV['HOTCH_FILTER'])
  hotch = if aggregate
    $hotch ||= Hotch.new(name, viewer: viewer, filter: filter)
  else
    caller = Kernel.caller_locations(1).first
    Hotch.new("#{name}:#{caller.path}:#{caller.lineno}", viewer: viewer, filter: filter)
  end

  hotch.report_at_exit
  hotch.run do
    yield
  end
end
