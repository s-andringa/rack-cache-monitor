module Rack
  module Cache
    class Monitor
      class Scheduler
        def initialize(interval, logger: nil)
          @interval = interval
          @logger   = logger
        end

        def set_callback(&block)
          @callback = block or raise ArgumentError, "no block given"
        end

        def start
          if !alive? && @callback
            @thread = Thread.new do
              loop do
                sleep(@interval)
                begin
                  @callback.call
                rescue => e
                  @logger.error "Unexpected error: #{e.inspect}" if @logger
                  break
                end
              end
            end
            true
          else
            false
          end
        end

        def stop
          if alive?
            @thread.kill
            true
          else
            false
          end
        end

        def alive?
          !!@thread && @thread.alive?
        end
      end
    end
  end
end
