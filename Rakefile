# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

begin
  require "rubocop/rake_task"

  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop
end

Rails.application.load_tasks

task default: [:rubocop, :spec]
