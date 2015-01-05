
COUNT = ENV.fetch('COUNT', 10_000)

def foo
  "x" * 23
end

def bar
  ["x"] * 23
end

COUNT.times do
  foo
  bar
end
