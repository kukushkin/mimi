module Mimi
  class Application
    class Runner
      include Mimi::Logger::Instance

      attr_reader :application_class, :application_instance

      def initialize(application_class)
        @application_class = application_class
        @application_instance = application_class.instance
      end

      def run
        application_instance.stop_requested = false
        init_signal_handlers
        emit(:configure)
        emit(:start)
        loop do
          break if application_instance.stop_requested
          emit(:tick)
          emit(:every)
          break if application_instance.stop_requested
          sleep Mimi::Application.module_options[:tick_interval]
        end
        emit(:stop)
        true
      rescue Exception => e
        # abort "FATAL: #{e}"
        abort "FATAL: #{e}"
      end

      def stop_by_signal(signal)
        # TODO: cant' run to log in the trap context
        # puts "Signal caught (#{signal}), exiting"
        application_instance.stop_requested = true
      end

      def emit(event)
        logger.debug "emit(#{event})"
        handlers = application_class.event_handlers.select { |h| h[:event] == event }
        handlers.each do |h|
          application_instance.instance_exec(&h[:block])
        end
      rescue Exception => e
        logger.fatal "Failed to process event '#{event}': #{e}"
        logger.debug e.backtrace.join("\n")
        raise
      end

      private

      def init_signal_handlers
        %w(INT TERM QUIT).each do |stop_signal|
          Signal.trap(stop_signal) { stop_by_signal(stop_signal) }
        end
        # Signal.trap('KILL') { stop_now! }
      end
    end # class Runner
  end # class Application
end # module Mimi
