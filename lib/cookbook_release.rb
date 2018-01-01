# frozen_string_literal: true

require "cookbook_release/github"
require "cookbook_release/sem_ver"
require "cookbook_release/version"
require "cookbook_release/tasks/berkshelf"
require "cookbook_release/tasks/change_log"
require "cookbook_release/tasks/release"
require "cookbook_release/tasks/stove"
require "cookbook_release/tasks/version_pull_request"
require "rake" unless defined? Rake

module CookbookRelease

  class RakeTasks

    def initialize(major_version, options = {})
      access_token = options[:access_token] || ENV["GITHUB_TOKEN"]
      repo = options[:repo] || ENV["GITHUB_REPO"]

      @github = CookbookRelease::Github.new(repo, access_token)
      @next_changelog = options[:next_changelog] || "next_changelog.tmp.md"
      @semver = CookbookRelease::SemVer.new(major_version)
      @git_number = ENV["FUTURE_RELEASE"] || @semver.git_number
    end

    def create_tasks!
      CookbookRelease::Tasks::Berkshelf.new.tasks!
      CookbookRelease::Tasks::ChangeLog.new(@git_number, @next_changelog).tasks!
      CookbookRelease::Tasks::Release.new(@github, @next_changelog, @semver).tasks!
      CookbookRelease::Tasks::Stove.new.tasks!
      CookbookRelease::Tasks::VersionPullRequest.new(@next_changelog).tasks!
    end

  end

end
