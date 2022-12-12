# frozen_string_literal: true

require "hotch"

class Hotch
  module Minitest
    # Usage in test/test_helper.rb:
    #
    #     require 'hotch/minitest'
    #
    #     Hotch::Minitest.run
    #     Hotch::Minitest.run(filter: /MyClass/)
    #     Hotch::Minitest.run(options: <stackprof options>)
    #     Hotch::Minitest.run(options: { limit: 200 })
    #
    def self.run(**options)
      ::Minitest.singleton_class.prepend Hotch::Minitest.aggregate(**options)
    end

    def self.aggregate(**options)
      Module.new do
        define_method(:run_one_method) do |*args|
          options[:aggregate] = true
          Hotch(**options) do
            super(*args)
          end
        end
      end
    end
  end
end
