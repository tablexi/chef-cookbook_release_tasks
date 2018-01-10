# frozen_string_literal: true

module CookbookRelease

  module Tasks

    class Release

      include Rake::DSL

      def initialize(github, next_changelog, semver, chef_env = nil)
        @chef_env = chef_env
        @github = github
        @next_changelog = next_changelog
        @semver = semver
      end

      def tasks!
        namespace :release do
          chef_env
          chef_server
          github
          supermarket
        end
      end

      def chef_env
        desc "Chef environment release"
        task chef_environment: ["berkshelf:setup"] do
          next unless @chef_env
          sh "echo '#{@semver.number}' > VERSION"
          Rake::Task["berkshelf:install"].execute
          sh "bundle exec berks apply #{@chef_env}"
          sh "rm VERSION"
        end
      end

      def chef_server
        desc "Chef server release"
        task chef_server: ["berkshelf:setup"] do
          sh "echo '#{@semver.number}' > VERSION"
          Rake::Task["berkshelf:install"].execute
          sh "bundle exec berks upload"
          sh "rm VERSION"
        end
      end

      def github
        desc "Github release"
        task github: ["changelog:next"] do
          changelog = IO.read(@next_changelog).split("\n").drop(2).join("\n")

          File.delete(@next_changelog)

          @github.create_release(
            @semver.git_number,
            body: changelog,
          )
        end
      end

      def supermarket
        desc "Chef supermarket release"
        task supermarket: ["stove:setup", "changelog:update"] do
          sh "echo '#{@semver.number}' > VERSION"
          sh "bundle exec stove --no-git"
          sh "rm VERSION"
        end
      end

    end

  end

end
