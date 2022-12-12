# frozen_string_literal: true

require "minitest/autorun"
require "hotch/minitest"
require "hotch/memory/minitest"

Hotch::Minitest.run
Hotch::Memory::Minitest.run

class ExampleTest < Minitest::Test
  def foo
    "x" * 23
  end

  def bar
    ["x"] * 23
  end

  def test_hotch
    10_000.times do
      foo
      bar
    end

    assert true
  end
end
