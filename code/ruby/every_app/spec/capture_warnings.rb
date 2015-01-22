# https://raw.githubusercontent.com/metric_fu/metric_fu/master/spec/capture_warnings.rb
require "rubygems" if RUBY_VERSION =~ /^1\.8/
require "bundler/setup"
require "rspec/core"
require "rspec/expectations"
require "tempfile"

stderr_file = Tempfile.new("app.stderr")
current_dir = Dir.pwd
bundle_dir = File.join(current_dir, "bundle")

RSpec.configure do |config|
  config.before(:suite) do
    $stderr.reopen(stderr_file.path)
    $VERBOSE = true
  end

  config.after(:suite) do
    stderr_file.rewind
    lines = stderr_file.read.split("\n").uniq
    stderr_file.close!

    $stderr.reopen(STDERR)

    app_warnings, other_warnings = lines.partition do |line|
      line.include?(current_dir) && !line.include?(bundle_dir)
    end

    if app_warnings.any?
      puts <<-WARNINGS
#{'-' * 30} app warnings: #{'-' * 30}

#{app_warnings.join("\n")}

#{'-' * 75}
      WARNINGS
    end

    if other_warnings.any?
      File.open("tmp/warnings.txt", "w") { |f| f.write(other_warnings.join("\n")) }
      puts
      puts "Non-app warnings written to tmp/warnings.txt"
      puts
    end

    # fail the build...
    raise "Failing build due to app warnings" if app_warnings.any?
  end
end
