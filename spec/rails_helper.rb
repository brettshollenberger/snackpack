ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'webmock/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.before(:all) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each, :logsql) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

  config.after(:each, :logsql) do
    ActiveRecord::Base.logger = nil
  end

  config.include FactoryGirl::Syntax::Methods
  config.include Requests::JsonHelpers, type: :request
end
