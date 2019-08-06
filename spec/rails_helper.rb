# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

require 'pry-rails'

# require 'database_cleaner'
# require 'database_cleaner/mongo'
# require 'factory_bot_rails'

Dir[File.join(File.dirname(__FILE__), 'shared_examples/**/*.rb')].each(&method(:require))

RSpec.configure do |config|
  # config.include FactoryBot::Syntax::Methods
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # config.before(:suite) do
    # DatabaseCleaner[:active_record].strategy = :transaction
    # DatabaseCleaner[:mongoid].strategy = :truncation
    # DatabaseCleaner.clean_with(:truncation)
  # end
  # config.around(:each) do |example|
    # DatabaseCleaner.cleaning do
      # example.run
    # end
  # end
end
