require 'allocation_tracer'

class Hotch
  def self.memory(name: $0)
    caller = Kernel.caller_locations(1).first
    name = "#{name}:#{caller.path}:#{caller.lineno}"
    memory = Memory.new(name)

    memory.report_at_exit
    memory.run do
      yield
    end
  end

  class Memory
    def initialize(name, ignore_paths: [])
      @name = name
      @ignore_paths = Array(ignore_paths || [])
      @report = nil
      @started = nil
    end

    def start
      ObjectSpace::AllocationTracer.setup [:path, :line, :type]
      ObjectSpace::AllocationTracer.start
      @started = true
    end

    def stop
      return unless @started
      results = ObjectSpace::AllocationTracer.stop
      @started = nil
      @report = Report.new(results, @ignore_paths)
    end

    def run
      start
      yield
    ensure
      stop
    end

    def report
      # TODO make it persistent (as CSV)
      yield @report
    end

    def report_at_exit
      return if defined? @at_exit_installed

      at_exit do
        stop

        report do |report|
          report.puts($stdout)
        end
      end

      @at_exit_installed = true
    end

    private

    def name
      @name.gsub(/\W+/, '_')
    end

    class Report
      def initialize(results, ignore_paths)
        @header = Line.new(*Line.members)
        @total = Line::Total.new
        @lines = results.map do |result|
          if line = Line.from_result(result, ignore_paths)
            @total.sum(line)
            line
          end
        end.compact
      end

      def format
        # TODO refactor
        max_lengths = Array.new(Line.members.size, 0)
        ([@header, @total] + @lines).each do |line|
          line.lengths.each.with_index do |length, i|
            max_lengths[i] = length if length > max_lengths[i]
          end
        end
        max_lengths.map { |len| "%#{len}s" }.join(" ")
      end

      def puts(io)
        fmt = format
        @header.puts(io, fmt)
        @lines.sort_by(&:count).each { |line| line.puts(io, fmt) }
        @total.puts(io, fmt)
      end

      class Line < Struct.new(:filename, :type, :count, :old_count, :total_age,
                              :min_age, :max_age, :total_memsize)
        # [
        #   [path, lineno, type],
        #   [count, old_count, total_age, min_age, max_age, total_memsize]
        # ]
        def self.from_result(result, ignore_paths)
          path, line, *args = result.flatten(1)
          return if ignore_paths.any? { |ip| ip == path || ip === path }
          filename = "#{strip_path(path)}:#{line}"
          new(filename, *args)
        end

        def puts(io, fmt)
          send = method(:send)
          io.puts fmt % members.map(&send)
        end

        def lengths
          members.map { |member| self[member].to_s.size }
        end

        private

        MAX_PATH_LENGTH = 50
        def self.strip_path(path)
          strip = %r{#{Regexp.union($LOAD_PATH)}/?}
          path.gsub!(strip, "")
          if path.size > MAX_PATH_LENGTH + 3
            # TODO Refactor
            "..." + path[-MAX_PATH_LENGTH..-1]
          else
            path
          end
        end

        class Total < Line
          def initialize
            super("TOTAL", "", 0, 0, 0, 0, 0, 0)
          end

          def sum(other)
            other.to_a.each.with_index do |value, i|
              self[i] += value if Numeric === value
            end
          end
        end
      end
    end
  end
end
