# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cookbook_release"

CookbookRelease::RakeTasks.new(10).create_tasks!

RSpec::Core::RakeTask.new(:spec)

task default: :spec
