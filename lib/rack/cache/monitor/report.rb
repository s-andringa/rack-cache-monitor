require "rack/cache/monitor/hash_aggregator"

module Rack
  module Cache
    class Monitor
      class Report
        attr_reader :counts

        def initialize(counts)
          @counts = counts
        end

        def fresh
          counts["fresh"]
        end

        def stale
          sum[/^stale/]
        end

        def stale_valid
          sum[/^stale, valid/]
        end

        def stale_invalid
          sum[/^stale, invalid/]
        end

        def miss
          sum[/^miss/]
        end

        def pass
          counts["pass"]
        end

        def total
          sum.*
        end

        def hitrate
          100 * (fresh.to_f / total) unless total.zero?
        end

        def to_h
          @counts.dup
        end

        def inspect
          "#<#{self.class} fresh: #{fresh}, stale: #{stale}, miss: #{miss}, pass: #{pass}>"
        end

        private

        def sum
          @sum ||= HashAggregator.new(counts) { |matches| matches.inject(0, :+) }
        end
      end
    end
  end
end
