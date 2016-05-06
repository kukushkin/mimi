require 'pathname'
require 'erb'

module Mimi
  class CLI
    class AppGenerator
      attr_reader :app_name, :target_path
      FILE_MAPPINGS = {
        'app/models/README.md' => 'app/models/README.md',
        'app/messaging/README.md' => 'app/messaging/README.md',
        'bin/start' => 'bin/start',
        'config/manifest.yml' => 'config/manifest.yml',
        'lib/file_name.rb' => 'lib/#{file_dirname}/#{file_basename}.rb',
        'lib/file_name/application.rb' => 'lib/#{file_name}/application.rb',
        'lib/file_name/version.rb' => 'lib/#{file_name}/version.rb',
        'lib/boot.rb' => 'lib/boot.rb',
        'Gemfile' => 'Gemfile',
        'Rakefile' => 'Rakefile',
        'app.env' => '.env',
        'app.gitignore' => '.gitignore'
      }
      FILE_MAPPINGS_EXEC = ['bin/start']

      APP_TEMPLATE_PATH = Pathname.new(__FILE__).dirname.join('template')

      def initialize(app_name, target_path = nil)
        @app_name = app_name
        @target_path = Pathname.new(target_path).expand_path
      end

      # Returns application name as class name.
      #
      # @example
      #   "some-my_app" -> "Some::MyApp"
      #
      def module_name
        name_parts = app_name.split('-').map do |word|
          word.gsub(/(^|_)(\w)/) { |m| m.chars.last.upcase }
        end
        name_parts.join('::')
      end

      # Returns module name split into parts
      #
      def module_name_parts
        module_name.split('::')
      end

      # Returns application name as file name.
      #
      # @example
      #   "some-my_app" -> "some/my_app"
      #
      def file_name
        app_name.split('-').join('/')
      end

      # Returns base part of the application name as file name.
      #
      # @example
      #   "some-my_app" -> "my_app"
      #
      def file_basename
        app_name.split('-').last
      end

      # Returns directory part of the application name as file name.
      #
      # @example
      #   "some-my_app" -> "some"
      #
      def file_dirname
        app_name.split('-')[0..-2].join('/')
      end

      def app_root_path
        target_path.join(app_name).expand_path
      end

      def generate(opts = {})
        raise "Application already exists: #{app_root_path}" if app_root_path.exist?
        install_path(app_root_path) unless opts[:dry_run]
        FILE_MAPPINGS.each do |from_file, to_file|
          to_file = eval "\"#{to_file}\""
          from_path = APP_TEMPLATE_PATH.join(from_file)
          to_path = app_root_path.join(to_file)
          puts "  #{from_path} -> #{to_path}"
          next if opts[:dry_run]
          if from_path.directory?
            install_path(to_path)
          else
            file_contents = File.read(from_path)
            file_processed = ERB.new(file_contents).result(binding)
            install_file(to_path, file_processed, FILE_MAPPINGS_EXEC.include?(from_file))
          end
        end
      end

      def install_path(path)
        FileUtils.mkdir_p(path)
      end

      def install_file(path, contents, executable = false)
        FileUtils.mkdir_p(path.dirname)
        File.open(path, 'w') do |f|
          f.puts contents
        end
        FileUtils.chmod(0755, path, verbose: true) if executable
      end
    end # class AppGenerator
  end # class CLI
end # module Mimi
