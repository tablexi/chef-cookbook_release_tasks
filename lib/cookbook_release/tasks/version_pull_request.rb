# frozen_string_literal: true

require "rake" unless defined? Rake

module CookbookRelease

  module Tasks

    class VersionPullRequest

      include Rake::DSL
      def initialize(next_changelog = nil)
        @next_changelog = next_changelog
      end

      def tasks!
        desc "Create/Update github release pull request"
        task version_pull_request: ["changelog:next"] do
          changelog = IO.read(@next_changelog).split("\n").drop(2).join("\n")

          File.delete(@next_changelog)

          @github.create_update_pr(
            "Ready to release",
            changelog,
          )
        end
      end

    end

  end

end
