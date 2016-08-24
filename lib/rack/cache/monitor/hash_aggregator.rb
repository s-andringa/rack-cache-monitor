module Rack
  module Cache
    class HashAggregator
      def initialize(hash, &block)
        @hash       = hash
        @aggregator = block || ->(v) { v }
      end

      def [](pattern)
        aggregate(matches(pattern))
      end

      def *
        aggregate(@hash.values)
      end

      private

      def aggregate(values)
        @aggregator.call(values)
      end

      def matches(pattern)
        @hash.select { |k, _| pattern === k }.values
      end
    end
  end
end
