# frozen_string_literal: true

module CookbookRelease

  module Tasks

    class Stove

      include Rake::DSL
      def tasks!
        namespace :stove do
          setup
        end
      end

      def setup
        desc "Setup stove using env variables"
        task :setup do
          if File.exist?("~/.stove")
            puts "Stove config file already exists"
            next
          end

          supermarket_login = ENV["SUPERMARKET_LOGIN"] || "ci"
          supermarket_key = ENV["SUPERMARKET_KEY"] || "~/.chef/ci.pem"

          unless File.exist?(supermarket_key)
            # On CI, also convert ENV variable to pem file
            if ENV["SUPERMARKET_KEY_PEM"]
              sh "mkdir -p #{File.dirname(supermarket_key)}"
              File.write(supermarket_key, ENV["SUPERMARKET_KEY_PEM"])
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
