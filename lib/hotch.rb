require 'stackprof'
require 'tmpdir'

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
    dump = File.open(File.join(dir, "profile.dump"), "wb")
    svg = File.join(File.join(dir, "profile.svg"))


    report.print_graphviz(nil, dump)

    dump.close

    system! "dot", "-Tsvg", "-o", svg, dump.path

    yield svg
  end

  def system!(*args)
    Kernel.system(*args) or raise "system call failed: #{args.join(' ')}"
  end

  def report_at_exit(viewer=ENV['HOTCH_VIEWER'])
    return if defined? @at_exit_installed

    at_exit do
      stop

      report do |svg|
        puts "Profile SVG: #{svg}"

        if viewer
          system viewer, svg
        end
      end
    end

    @at_exit_installed = true
  end

  private

  def name
    @name.gsub(/\W+/, '_')
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
