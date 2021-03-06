# frozen_string_literal: true

require "octokit"

module CookbookRelease

  class Github

    def initialize(repo, access_token)
      @repo = repo
      @client = Octokit::Client.new(access_token: access_token)
    end

    def create_release(tag, options = {})
      options[:name] = "Release #{tag}" unless options.key?(:name)
      options[:target_commitish] = commit_sha unless options.key?(:target_commitish)

      begin
        @client.create_release(@repo, tag, options) if target_commitish_exist?(options[:target_commitish])
      rescue Octokit::UnprocessableEntity
        raise "Release already exists!"
      end
      puts "Successfully released"
    end

    def create_update_pr(title, body, base = "master", head = "develop")
      issue_num = get_pr(base, head, title)
      if issue_num
        @client.update_pull_request(
          @repo,
          issue_num,
          title,
          body,
        )
      else
        begin
          @client.create_pull_request(
            @repo,
            base,
            head,
            title,
            body,
          )
        rescue Octokit::UnprocessableEntity
          puts "Pull request unnecessary"
        end
      end
    end

    private

    def commit_sha
      `git rev-parse HEAD`.delete!("\n")
    end

    def get_pr(base, head, title)
      begin
        prs = @client.pull_requests(
          @repo,
          base: base,
          head: head,
          state: "open",
        )

        prs.each do |pr|
          return pr.number if pr.title == title
        end
      # Ignore error, if there are no PR's to return.
      rescue Octokit::NotFound
      end
      false
    end

    def target_commitish_exist?(sha)
      @client.commit(@repo, sha)
    rescue Octokit::NotFound
      puts "target_commitsh: #{sha} not on remote"
      return false
    end

  end

end
