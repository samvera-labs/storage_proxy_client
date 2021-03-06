require "bundler/setup"
require "storage_proxy_api"
require 'webmock/rspec'
WebMock.disable_net_connect!

require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
