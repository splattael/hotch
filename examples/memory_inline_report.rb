require 'hotch/memory'

ary = []

puts Hotch::Memory.report("1") {
  ary << "string"
}

puts Hotch::Memory.report("2") {
  ary << "another"
}

puts Hotch::Memory.report("3") {
  ary.join(" ")
}
