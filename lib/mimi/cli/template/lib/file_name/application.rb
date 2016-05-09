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

  on :start do
    logger.info "** #{self.class.name_version} started"
  end

  every 1.second do
    logger.info "** tick"
  end

  on :stop do
    logger.info "** #{self.class.name_version} stopped"
  end
end # class <%= module_name %>::Application
