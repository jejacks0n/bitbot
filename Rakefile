#!/usr/bin/env rake

# Bundler
begin
  require "bundler/gem_helper"
  Bundler::GemHelper.install_tasks
rescue LoadError
end

# RSpec
begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end
