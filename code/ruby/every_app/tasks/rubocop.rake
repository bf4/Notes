if ENV["FULL_BUILD"] != "true" # skip on Travis
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:rubocop)
end
