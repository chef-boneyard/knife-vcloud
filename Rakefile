require "bundler"
require "bundler/setup"
require "bundler/gem_tasks"
require "chefstyle"
require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

task default: [:rubocop, :spec]
