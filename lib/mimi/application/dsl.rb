module Mimi
  class Application
    module DSL
      extend ActiveSupport::Concern

      class_methods do
        #
        #
        def configure(opts = nil, &block)
          if opts
            super(opts)
          else
            register_event_handler(:configure, block)
          end
        end

        # Registers handler
        #
        def on(event, &block)
          register_event_handler(event, block)
        end

        # Registers 'every <sec>' handler
        #
        def every(seconds, &block)
          if !seconds.is_a?(Numeric) || seconds <= 0
            raise ArgumentError, 'Positive number of seconds is expected as an argument'
          end
          wrap_block = proc do
            @every_block_opts ||= {}
            opts = @every_block_opts[block.object_id] || {}
            next_run_at = opts[:next_run_at]
            next if next_run_at && next_run_at >= Time.now
            block.call
            opts[:next_run_at] = Time.now + seconds
            @every_block_opts[block.object_id] = opts
          end
          register_event_handler(:every, wrap_block)
        end

        # Registers event handler
        #
        def register_event_handler(event, block, opts = {})
          @event_handlers ||= []
          @event_handlers << { event: event, block: block, options: opts }
        end

        # Returns list of event handlers, including those defined in a subclass
        #
        def event_handlers
          local_event_handlers = @event_handlers || []
          return local_event_handlers unless superclass.respond_to?(:event_handlers)
          superclass.event_handlers + local_event_handlers
        end
      end
    end # module DSL
  end # class Application
end # module Mimi
