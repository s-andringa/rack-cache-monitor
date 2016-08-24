require "logger"
require "rack/cache/monitor/version"
require "rack/cache/monitor/forkable"
require "rack/cache/monitor/forkable_counter"
require "rack/cache/monitor/scheduler"
require "rack/cache/monitor/report"

module Rack
  module Cache
    class Monitor
      prepend Forkable

      DEFAULT_INTERVAL = 20 # seconds
      TRACE_HEADER = "X-Rack-Cache".freeze

      def initialize(app, interval_in_seconds: nil, counter: nil, logger: nil, scheduler: nil, log_level: Logger::INFO, report_on_exit: true, &block)
        @app            = app
        @counter        = counter || ForkableCounter.new
        @logger         = logger || default_logger(log_level)
        @reporter       = block or raise ArgumentError, "no block given"
        @report_on_exit = !!report_on_exit

        interval_in_seconds ||= if ENV['RACK_CACHE_MONITOR_INTERVAL']
                              Float(ENV['RACK_CACHE_MONITOR_INTERVAL'])
                            else
                              DEFAULT_INTERVAL
                            end

        @scheduler = scheduler || Scheduler.new(logger: @logger)
        @scheduler.every(interval_in_seconds){ report }.on_error{ @report_on_exit = false; stop!(false) }.start
        @logger.info "Started monitoring, reporting every #{interval_in_seconds} seconds"

        at_exit do
          unless fork?
            stop!
            report if @report_on_exit
          end
        end
      end

      def call(env)
        @app.call(env).tap do |_, headers, _|
          if running? && %w(GET HEAD).include?(env['REQUEST_METHOD'])
            if trace = headers[TRACE_HEADER]
              @counter.increment(trace)
            end
          end
        end
      end

      private

      def report
        counts = @counter.flush
        report = Report.new(counts)

        @reporter.call(report)
      end

      def stop!(stop_scheduler = true)
        if running?
          @logger.info "Gracefully stopping monitor..."
          @scheduler.stop if stop_scheduler
          @counter.close
        end
      end

      # Should be observable by parent process as well as child processes, therefore
      # we look at the forkable counter, which will be closed when the monitor has stopped
      # in the main process.
      #
      def running?
        !@counter.closed?
      end

      def default_logger(level)
        Logger.new(STDOUT).tap do |logger|
          logger.level = level
          logger.formatter = ->(severity, time, progname, msg) {
            "[#{$$}] [#{self.class}] #{msg}\n"
          }
        end
      end
    end
  end
end
