module Rack
  module Cache
    class Monitor
      module Forkable
        def initialize(*)
          @parent_pid = $$
          super
        end

        def fork?
          @parent_pid != $$
        end
      end
    end
  end
end