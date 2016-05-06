require 'mimi'
# require 'mimi/db'
# require 'mimi/messaging'

class <%= module_name %>::Application < Mimi::Application
  NAME = '<%= app_name %>'.freeze
  VERSION = '0.0.1'.freeze

  configure do
    # use Mimi::DB
    # use Mimi::Messaging
  end
end # class <%= module_name %>::Application
