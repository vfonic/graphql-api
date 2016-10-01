require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "graphite"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.api_only = true

    config.autoload_paths << Rails.root.join('app', 'commands')
    config.autoload_paths << Rails.root.join('app', 'queries')
    config.autoload_paths << Rails.root.join('lib')
  end
end

