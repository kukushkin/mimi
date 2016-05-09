require 'bundler/setup'
Bundler.setup
$LOAD_PATH.unshift(__dir__)

require_relative '../lib/<%= file_name %>'
require 'support/fixtures'
require 'support/envvars'

with_env_vars(fixture_path('env.test')) do
  # Load and configure application
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
