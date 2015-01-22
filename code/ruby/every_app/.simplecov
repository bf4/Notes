# https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config
# see https://github.com/colszowka/simplecov/blob/master/lib/simplecov/defaults.rb
# vim: set ft=ruby
@minimum_coverage = ENV.fetch("COVERAGE_MINIMUM") { 100.0 }.to_f.round(2)
SimpleCov.profiles.define "gem" do
  load_profile  "test_frameworks"
  coverage_dir "reports/coverage"

  add_group "Long files" do |src_file|
    src_file.lines.count > 100
  end
  class MaxLinesFilter < SimpleCov::Filter
    def matches?(source_file)
      source_file.lines.count < filter_argument
    end
  end
  add_group "Short files", MaxLinesFilter.new(5)

  # Exclude these paths from analysis
  add_filter "bundle"
  add_filter "bin"
  add_filter "tasks"

  # https://github.com/colszowka/simplecov/blob/v0.9.1/lib/simplecov/defaults.rb#L60
  # minimum_coverage @minimum_coverage
end

## RUN SIMPLECOV
if defined?(@running_tests)
  @running_tests = false
else
  @running_tests = caller.any? {|line| line =~ /exe\/rspec/ }
end
SimpleCov.start "gem" if @running_tests
if ENV["COVERAGE"] =~ /\Atrue\z/i
  puts "[COVERAGE] Running with SimpleCov HTML Formatter"
  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter]
else
  SimpleCov.formatters = []
end
SimpleCov.at_exit do
  SimpleCov.result.format!
  percent = Float(SimpleCov.result.covered_percent)
  if percent < @minimum_coverage
    abort "Spec coverage was not high enough: #{percent.round(2)} is > #{@minimum_coverage}%"
  else
    puts "Nice job! Spec coverage is still above #{@minimum_coverage}%"
  end
end
