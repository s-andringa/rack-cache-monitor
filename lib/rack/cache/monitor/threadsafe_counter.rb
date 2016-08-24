require "rack/cache/monitor/counter"

module Rack
  module Cache
    class Monitor
      class ThreadsafeCounter < Counter
        def initialize(lock = nil)
          @lock = lock || Mutex.new
          super()
        end

        def increment(trace)
          @lock.synchronize { super }
        end

        def flush
          @lock.synchronize { super }
        end
      end
    end
  end
end