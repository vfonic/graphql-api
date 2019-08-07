# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/api/version'

Gem::Specification.new do |spec|
  spec.name        = 'graphql-api'
  spec.version     = GraphQL::Api::VERSION
  spec.authors     = ['Colin Walker']
  spec.email       = ['colinwalker270@gmail.com']
  spec.homepage    = 'https://github.com/coldog/graphql-api'
  spec.summary     = 'Rails API GraphQL connection with ease'
  spec.license     = 'MIT'

  spec.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'graphql', '~> 1.4.0'
  spec.add_dependency 'rails', '>= 4.2.6'

  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'pry-rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'sqlite3'
end
