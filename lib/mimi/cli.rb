require 'thor'
require 'pathname'

module Mimi
  class CLI < Thor
    map %w(--version -v) => :__print_version
    desc '--version, -v', 'Display version'
    def __print_version
      puts "mimi v#{Mimi::VERSION}"
    end

    desc 'create NAME [PATH]', 'Create application in the specified directory'
    def create(name, path = Pathname.pwd)
      app_generator = Mimi::CLI::AppGenerator.new(name, path)
      puts "         name: #{app_generator.app_name}"
      puts "         path: #{app_generator.target_path}"
      puts "app_root_path: #{app_generator.app_root_path}"
      puts "  module_name: #{app_generator.module_name}"
      puts
      app_generator.generate # (dry_run: truew)
    end

    private

    def app_name_to_class_name(name)
    end
  end # class CLI
end # module Mimi

require_relative 'cli/app_generator'
