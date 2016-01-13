class Hotch
  module Minitest
    # Usage in test/test_helper.rb:
    #
    #     require 'hotch/minitest'
    #
    def self.aggregate
      Module.new do
        def run_one_method(*args)
          Hotch(aggregate: true) do
            super(*args)
          end
        end
      end
    end
  end
end

require "hotch"
Minitest.singleton_class.prepend Hotch::Minitest.aggregate
