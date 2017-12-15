# frozen_string_literal: true

module CookbookRelease

  module Tasks

    class Berkshelf

      include Rake::DSL
      def tasks!
        namespace :berkshelf do
          setup
        end
      end

      def setup
        desc "Setup berkshelf using env variables"
        task "setup" do
          berkshelf_config = File.join(ENV["HOME"], ".berkshelf/config.json")
          if File.exist?(berkshelf_config)
            puts "Berkshelf config file already exists"
            next
          end

          sh "mkdir -p #{File.dirname(berkshelf_config)}"

          chef_server = ENV["CHEF_SERVER"] || "https://chef.tablexi.com/organizations/tablexi"
          node_name = ENV["NODE_NAME"] || "ci"
          client_key = ENV["CLIENT_KEY"] || "/ci.pem"

          unless File.exist?(client_key)
            # On CI, also convert ENV variable to pem file
            if ENV["CHEF_CLIENT_PEM"]
              sh "mkdir -p #{File.dirname(client_key)}"
              File.write(client_key, ENV["CHEF_CLIENT_PEM"])
            else
              raise "Chef client key missing #{client_key}"
            end
          end

          config = {
            "chef" => {
              "chef_server_url" => chef_server,
              "node_name" => node_name,
              "client_key" => client_key,
            },
          }

          require "json"

          File.write(berkshelf_config, config.to_json)
        end
      end

    end

  end

end