require 'hotch'

COUNT = ENV.fetch('COUNT', 10_000)

def foo
  "x" * 23
end

def bar
  ["x"] * 23
end

Hotch(aggregate: false) do
  COUNT.times do
    foo
  end
end

Hotch() do
  COUNT.times do
    bar
  end
end
