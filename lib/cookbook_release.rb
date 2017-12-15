require 'rake' unless defined? Rake

require "cookbook_release/github"
require "cookbook_release/sem_ver"
require "cookbook_release/version"
module CookbookRelease

  class RakeTasks

    include Rake::DSL

    def initialize(_major, options = {})
      access_token = options[:access_token] || nil
      repo = options[:repo] || nil

      @github = CookbookRelease::Github.new(repo, access_token)
      @next_changelog = options[:next_changelog] || "next_changelog.tmp.md"
      @semver = CookbookRelease::SemVer.new(_major)
    end

    def create_tasks!
      desc "Setup berkshelf using env variables"
      task 'berkshelf:setup' do
        berkshelf_config = File.join(ENV['HOME'],'.berkshelf/config.json')
        if File.exist?(berkshelf_config)
          puts 'Berkshelf config file already exists'
          next
        end

        sh "mkdir -p #{File.dirname(berkshelf_config)}"

        chef_server = ENV['CHEF_SERVER'] || 'https://chef.tablexi.com/organizations/tablexi'
        node_name = ENV['NODE_NAME'] || 'ci'
        client_key = ENV['CLIENT_KEY'] || '/ci.pem'

        unless File.exist?(client_key)
          # On CI, also convert ENV variable to pem file
          if ENV['CHEF_CLIENT_PEM']
            sh "mkdir -p #{File.dirname(client_key)}"
            File.write(client_key, ENV['CHEF_CLIENT_PEM'])
          else
            raise "Chef client key missing #{client_key}"
          end
        end

        config = {
          'chef' => {
            'chef_server_url' => chef_server,
            'node_name' => node_name,
            'client_key' => client_key
          }
        }

        require 'json'

        File.write(berkshelf_config, config.to_json)
      end

      namespace :changelog do
        desc "Update changelog with supplied "
        task :update do
          future_release = ENV['FUTURE_RELEASE'] || @semver.git_number
          sh "bundle exec github_changelog_generator --future-release #{future_release} > /dev/null"
        end

        desc "Changelog for next only"
        task :next do
          future_release = ENV['FUTURE_RELEASE'] || @semver.git_number
          options =  "--unreleased-only --base '' --output #{@next_changelog} --future-release #{future_release} > /dev/null"

          sh "bundle exec github_changelog_generator #{options}"

          log = IO
            .read(@next_changelog) # Read Changelog
            .split("\n") # convert to array for easier parsing
            .drop(3).unshift("Release #{future_release}\n") # Update header
            .reverse.drop(1).reverse # Remove footer
            .join("\n") # convert back to string

          File.write(@next_changelog, log)
        end
      end

      desc "Create/Update release pull request"
      task version_pull_request: [ 'changelog:next' ] do
        changelog = IO.read(@next_changelog).split("\n").drop(2).join("\n")

        File.delete(@next_changelog)

        @github.create_update_pr(
          "Ready to release",
          changelog
        )
      end

      namespace :release do
        desc "Github release"
        task github: [ 'changelog:next' ] do

          changelog = IO.read(@next_changelog).split("\n").drop(2).join("\n")

          File.delete(@next_changelog)

          @github.create_release(
            @semver.git_number,
            {
              body: changelog,
            }
          )
        end

        desc "Chef server release"
        task chef_server: ["berkshelf:setup"] do
          sh "echo '#{@semver.number}' > VERSION"
          sh 'bundle exec berks upload'
          sh 'rm VERSION'
        end

        desc "Chef supermarket upload"
        task supermarket: ["stove:setup", "changelog:update"] do
          sh "echo '#{@semver.number}' > VERSION"
          sh 'bundle exec stove --no-git'
          sh 'rm VERSION'
        end
      end

      namespace :stove do
        desc "Setup stove using env variables"
        task :setup do
          if File.exist?('~/.stove')
            puts 'Stove config file already exists'
            next
          end

          supermarket_login = ENV['SUPERMARKET_LOGIN'] || 'ci'
          supermarket_key = ENV['SUPERMARKET_KEY'] || '~/.chef/ci.pem'

          unless File.exist?(supermarket_key)
            # On CI, also convert ENV variable to pem file
            if ENV['SUPERMARKET_KEY_PEM']
              sh "mkdir -p #{File.dirname(supermarket_key)}"
              File.write(supermarket_key, ENV['SUPERMARKET_KEY_PEM'])
            else
              raise "Chef supermarket key missing #{supermarket_key}"
            end
          end

          sh "bundle exec stove login --username #{supermarket_login} --key #{supermarket_key}"
        end
      end
    end
  end
end
