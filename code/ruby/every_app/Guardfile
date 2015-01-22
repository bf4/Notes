# More info about guard files at https://github.com/guard/guard#readme
# Always run guard with bin/guard
require "guard"
require "listen"
require "guard/rspec"
require "guard/bundler"
[
  "rb-fchange",
  "rb-fsevent",
  "terminal-notifier-guard"
].each do |notifier|
  begin
    require notifier
    puts "Loaded notifier #{notifier}"
  rescue LoadError
  end
end

# For debugging, take a look at https://github.com/guard/guard/issues/360#issuecomment-44087831
# TL;DR try
# interactor :off
# notification :off
# LISTEN_GEM_DEBUGGING=2 bundle exec guard -d

# Uncomment and set this to only include directories you want to watch
# directories %(app lib config test spec feature)
# By default .rbx, .bundle, .DS_Store, .git, .hg ,.svn, bundle, log,
# tmp, vendor/bundle are ignored.
ignore %r{^(coverage|db|bundle)}

p runner_cmd = "bin/rspec"
rspec_opts = {
  all_on_start: false,
  all_after_pass: false,
  notification: true,
  failed_mode: :keep,
  cmd: "#{runner_cmd} --format progress --color"
}
guard :rspec, rspec_opts do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)
end

guard :bundler do
  watch("Gemfile")
end
