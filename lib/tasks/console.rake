desc 'Start development console'
task console: :"application:configure" do
  require 'pry'
  puts "** @application: #{@application.class.name_version}, used modules: #{Mimi.used_modules.join(', ')}"
  puts '** run "Mimi.start" to start modules' unless Mimi.used_modules.empty?
  Pry.start
end

namespace :console do
  desc 'Run development console in debug mode'
  task :debug do
    Mimi::Logger.configure(level: :debug)
    ENV['log_level'] = 'debug'
    Rake::Task['console'].invoke
  end
end
