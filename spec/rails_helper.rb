# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../dummy/config/environment.rb", __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

require 'pry-rails'

require 'database_cleaner'
require 'factory_bot_rails'

Dir[File.join(File.dirname(__FILE__), 'shared_examples/**/*.rb')].each(&method(:require))

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
