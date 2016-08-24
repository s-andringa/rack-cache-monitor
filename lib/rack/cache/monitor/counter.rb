module Rack
  module Cache
    class Monitor::Counter
      def initialize
        reset_counts
      end

      def increment(trace)
        @counts[trace] += 1
      end

      def flush
        @counts.tap { reset_counts }
      end

      private

      def reset_counts
        @counts = Hash.new(0)
      end
    end
  end
end