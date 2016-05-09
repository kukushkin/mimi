require 'dotenv'

# Runs block with ENV variables loaded from specified file,
# restores original ENV variables after.
#
# @example
#   with_env_vars('.env.test') do
#     application.config.load
#   end
#
def with_env_vars(filename = nil, &_block)
  original_env_vars = ENV.to_hash
  Dotenv.load(filename) if filename
  yield
ensure
  ENV.replace(original_env_vars)
end
