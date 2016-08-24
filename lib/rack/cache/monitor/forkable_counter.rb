require "rack/cache/monitor/threadsafe_counter"
require "rack/cache/monitor/forkable"

module Rack
  module Cache
    class Monitor

      # In multi worker webservers such as Puma the middleware is created in
      # the parent process, but called from forked child processes.
      #
      # Our monitor thread only runs inside the parent process - as threads are
      # killed when forked - and from there it cannot observe changes made in
      # child processes.
      #
      # This counter wrapper deals with this by forwarding increments to the
      # process it was created in by means of a pipe.
      #
      # Flushing is only available to the process in which the object was
      # created.
      #
      class ForkableCounter < ThreadsafeCounter
        class Error < StandardError; end
        prepend Forkable

        RECORD_SEPARATOR = ":::".freeze

        def initialize(*)
          @fork_r, @parent_w = IO.pipe

          @listener = start_listener!
          @listener.abort_on_exception = true

          super
        end

        def increment(key)
          raise Error, "#{self.class} closed" if closed?

          fork? ? fwd_to_parent(key) : super
        end

        def flush
          raise Error, "Cannot flush from forked process (pid #{Process.pid})" if fork?

          super
        end

        def close
          @listener.kill
          @parent_w.close unless @parent_w.closed?
          @fork_r.close unless @fork_r.closed?
        end

        def closed?
          @parent_w.closed?
        end

        private

        # The listener thread won't survive forks, so it will always only be running
        # inside the parent process. That should be enough to avoid infinite loops.
        #
        def start_listener!
          Thread.new do
            loop do
              increment(Marshal.load(@fork_r.gets(RECORD_SEPARATOR)))
            end
          end
        end

        def fwd_to_parent(key)
          @parent_w.print(Marshal.dump(key), RECORD_SEPARATOR)
        end
      end
    end
  end
end