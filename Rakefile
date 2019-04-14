begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

# useful bundler gem tasks
Bundler::GemHelper.install_tasks

# load in rspec tasks
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

# setup the default task
task default: [:spec]
