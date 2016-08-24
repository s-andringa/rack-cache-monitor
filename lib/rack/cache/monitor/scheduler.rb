module Rack
  module Cache
    class Monitor
      class Scheduler
        def initialize(logger: nil)
          @logger = logger
        end

        def every(interval, &block)
          @interval = interval
          @callback = block or raise ArgumentError, "no block given"
          self
        end

        def on_error(&block)
          @on_error = block or raise ArgumentError, "no block given"
          self
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
                  @on_error.call if @on_error rescue nil
                  break
                end
              end
            end
            @thread.abort_on_exception = true
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
