require 'stackprof'

class Hotch
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def start(*args)
    StackProf.start(*args)
  end

  def stop
    StackProf.stop
  end

  def run(*args)
    start(*args)
  ensure
    stop
  end

  def results
    StackProf.results
  end

  def report
    dir = Dir.mktmpdir("hotch.#{name}")
    dump = File.open(File.join(dir, "profile.dump"), "wb")
    svg = File.join(File.join(dir, "profile.svg"))

    StackProf::Report.new(results).print_graphviz(nil, dump)

    dump.close

    system! "dot", "-Tsvg", "-o", svg, dump.path

    yield svg
  end

  def system!(*args)
    Kernel.system(*args) or raise "system call failed: #{args.join(' ')}"
  end
end

def Hotch()

end
