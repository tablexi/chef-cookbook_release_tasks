# frozen_string_literal: true

module CookbookRelease

  module Tasks

    class ChangeLog

      include Rake::DSL

      def initialize(future_release)
        @future_release = ENV["FUTURE_RELEASE"] || future_release
      end

      def tasks!
        namespace :changelog do
          next_release
          update
        end
      end

      def next_release
        desc "Changelog for next version only"
        task :next do
          options =  "--unreleased-only --base '' --output #{@next_changelog} --future-release #{@future_release} > /dev/null"

          sh "bundle exec github_changelog_generator #{options}"

          log = IO
                .read(@next_changelog) # Read Changelog
                .split("\n") # convert to array for easier parsing
                .drop(3).unshift("Release #{@future_release}\n") # Update header
                .reverse.drop(1).reverse # Remove footer
                .join("\n") # convert back to string

          File.write(@next_changelog, log)
        end
      end

      def update
        desc "Update changelog"
        task :update do
          sh "bundle exec github_changelog_generator --future-release #{@future_release} > /dev/null"
        end
      end

    end

  end

end
