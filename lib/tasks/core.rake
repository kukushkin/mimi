require 'mimi/console'

extend Mimi::Console::Colors
extend Mimi::Console::Colors::Disabled unless STDOUT.isatty

#
# Include this task as dependency to require application instantiation
#
task :application do
  @application_runner = Mimi::Application.runner
  @application = @application_runner.application_instance
  define_method :logger do
    @application.logger
  end
end

namespace :application do
  # Include this task as dependency to require application instantiation and startup
  #
  task configure: :application do
    @application_runner.emit(:configure)
  end

  # Include this task as dependency to require application instantiation, startup
  # and starting of all modules
  #
  task environment: [:application, :"application:configure"] do
    @application_runner.emit(:start)
  end
end
