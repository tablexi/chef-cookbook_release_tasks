# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cookbook_release_tasks/version"

Gem::Specification.new do |spec|
  spec.name          = "cookbook_release_tasks"
  spec.version       = CookbookReleaseTasks::VERSION
  spec.authors       = ["Table XI"]
  spec.email         = ["sysadmin@tablexi.com"]

  spec.summary       = "Rake tasks to assist with releasing your Chef cookbook."
  spec.description   = "Rake tasks to assist with releasing your Chef cookbook."
  spec.homepage      = "https://github.com/tablexi/cookbook_release_tasks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"

  spec.add_dependency "berkshelf"
  spec.add_dependency "github_changelog_generator"
  spec.add_dependency "stove"
end
