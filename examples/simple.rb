require 'hotch'

COUNT = ENV.fetch('COUNT', 1_000_000)

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

Hotch(mode: :cpu) do
  COUNT.times do
    bar
  end
end
