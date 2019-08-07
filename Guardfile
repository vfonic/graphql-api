# frozen_string_literal: true

rubocop_options = {
  all_on_start: false,
  cli: '-DES -c ../../shopify_apps/stylecheck/config/rubocop.yml --safe-auto-correct'
}

guard :rubocop, rubocop_options do
  watch(/.+\.rb$/)
  watch(/.+\.rake$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

rspec_options = {
  # results_file: File.expand_path('tmp/guard_rspec_results.txt'),
  #############################
  # BECAUSE spring doesn't seem to work well with simplecov, choose
  # between the following two.
  # slow but good coverage
  # cmd: "bin/rspec -p",
  # fast but no coverage
  cmd: 'rspec',
  #############################
  failed_mode: :focus,
  bundler_env: :clean_env
}

guard :rspec, rspec_options do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # watch /app files
  watch(%r{^app/(.+)/graphql/api/(.+).rb$}) do |m|
    "spec/#{m[1]}/graphql/api/#{m[2]}_spec.rb"
  end
end
