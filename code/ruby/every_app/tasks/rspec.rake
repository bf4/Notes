begin
  require "rspec/core/rake_task"
rescue LoadError
else
  # see https://github.com/rspec/rspec-rails/blob/3-1-maintenance/lib/rspec-rails.rb#L13
  # https://github.com/rspec/rspec-rails/blob/3-1-maintenance/lib/rspec/rails/tasks/rspec.rake#L13
  Rake::Task["spec"].clear
  Rake::Task["spec:prepare"].clear
  RSpec::Core::RakeTask.new(:spec => "spec:prepare")

  namespace :spec do
    types = begin
              dirs = Dir['./spec/**/*_spec.rb'].
                map { |f| f.sub(/^\.\/(spec\/\w+)\/.*/, '\\1') }.
                uniq.
                select { |f| File.directory?(f) }
              Hash[dirs.map { |d| [d.split('/').last, d] }]
            end

    task :prepare do
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = 'test'
    end

    types.each do |type, dir|
      desc "Run the code examples in #{dir}"
      RSpec::Core::RakeTask.new(type => "spec:prepare") do |t|
        t.pattern = "./#{dir}/**/*_spec.rb"
        t.verbose = false

        # we require spec_helper so we don't get an RSpec warning about
        # examples being defined before configuration.
        t.ruby_opts = "-I./spec -rrspec -r./spec/capture_warnings -rspec_helper"
        t.rspec_opts = %w[--format progress] if ENV["FULL_BUILD"]
      end
    end
  end
end
