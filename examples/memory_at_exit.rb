# frozen_string_literal: true

require "hotch/memory"

ary = []

Hotch.memory do
  ary << "string"
end

Hotch.memory do
  ary << "another"
end

Hotch.memory do
  ary.join(" ")
end
