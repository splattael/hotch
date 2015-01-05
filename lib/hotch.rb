require 'stackprof'

class Hotch
  def initialize
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
end

def Hotch()

end
