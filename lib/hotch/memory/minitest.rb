require "hotch/memory"

class Hotch
  class Memory
    module Minitest
      # Usage in test/test_helper.rb:
      #
      #     require 'hotch/memory/minitest'
      #
      #     Hotch::Memory::Minitest.run
      #     Hotch::Memory::Minitest.run(name: "my name")
      def self.run(**options)
        ::Minitest.singleton_class.prepend Hotch::Memory::Minitest.aggregate(**options)
      end

      def self.aggregate(**options)
        Module.new do
          define_method(:run_one_method) do |*args|
            options[:aggregate] = true
            Hotch.memory(**options) do
              super(*args)
            end
          end
        end
      end
    end
  end
end
