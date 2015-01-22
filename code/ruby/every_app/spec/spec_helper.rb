require "bundler/setup"
require "simplecov" # see .simplecov at bottom for run options

# Requires supaorting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
require "pathname"
@app_root = Pathname File.expand_path("../..", __FILE__)
def app_root
  @app_root
end
Dir[app_root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  # Skip specs tagged `:slow` unless SLOW_SPECS is set
  config.filter_run_excluding :slow unless ENV["SLOW_SPECS"]
  # End specs on first failure if FAIL_FAST is set
  config.fail_fast = ENV.include?("FAIL_FAST")
  config.order = :rand
  config.color = true
  config.disable_monkey_patching!
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  # :suite after/before all specs
  # :each every describe block
  # :all every it block
end
