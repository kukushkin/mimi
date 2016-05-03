require 'mimi/logger'
require 'mimi/config'
require 'singleton'

require_relative 'application/dsl'
require_relative 'application/runner'

module Mimi
  class Application
    include Mimi::Core::Module
    include Mimi::Logger::Instance
    include Singleton
    include DSL

    default_options(
      manifest_filename: 'config/manifest.yml',
      tick_interval: 1.second
    )

    def self.module_path
      Pathname.new(__dir__).join('..', '..').expand_path
    end

    configure do
      config # read config or fail
      logger.level = config.log_level if config.include?(:log_level)
      logger.debug "Configuring the application: #{config.params}"
      # TODO: application-wide configuration
    end

    on :start do
      logger.debug "Starting the application: #{self.class}"
      Mimi.start
    end

    on :tick do
      # nothing
    end

    on :stop do
      logger.debug "Shutting down the application: #{self.class}"
      Mimi.stop
    end

    def self.manifest_filename
      Mimi.app_path_to(Mimi::Application.module_options[:manifest_filename])
    end

    def use(mod, opts = nil)
      Mimi.use(mod, opts || config.to_h)
    end

    def config
      @config ||= Mimi::Config.new(self.class.manifest_filename)
    end

    def self.inherited(subclass)
      super
      @default_application_class = subclass
    end

    def self.run(application_class = nil)
      runner(application_class).run
    end

    def self.runner(application_class = nil)
      return @runner if @runner
      application_class ||= @default_application_class || self
      @runner = Mimi::Application::Runner.new(application_class)
    end

    attr_accessor :stop_requested
    def stop
      self.stop_requested = true
    end

    def self.name_version
      name = defined?(self::NAME) ? self::NAME : '<unnamed>'
      version = defined?(self::VERSION) ? self::VERSION : '<unknown>'
      "#{name} v#{version}"
    end
  end # class Application
end # module Mimi
