require 'stackprof'
require 'tmpdir'

require 'hotch/monkey_patches'

class Hotch
  attr_reader :name

  def initialize(name)
    @name = name
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

  def report_at_exit(viewer=ENV['HOTCH_VIEWER'])
    return if defined? @at_exit_installed

    at_exit do
      stop

      report do |svg|
        puts "Profile SVG: #{svg}"

        if viewer
          Kernel.system viewer, svg
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
      report.print_graphviz(nil, fh)
    end
    path
  end

  def convert_svg(dir, dot, file)
    svg = File.join(dir, file)
    system("dot", "-Tsvg", "-o", svg, dot) or raise "dot failed"
    svg
  end
end

def Hotch(aggregate: true)
  hotch = if aggregate
    $hotch ||= Hotch.new($0)
  else
    caller = Kernel.caller_locations(1).first
    Hotch.new("#$0:#{caller.path}:#{caller.lineno}")
  end

  hotch.report_at_exit
  hotch.run do
    yield
  end
end
