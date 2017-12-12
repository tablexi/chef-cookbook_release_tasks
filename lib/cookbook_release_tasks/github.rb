require 'octokit'

module CookbookReleaseTasks
  class Github
    def initialize(repo = nil, access_token = nil)
      @repo = repo || ENV['GITHUB_REPO']
      @client = Octokit::Client.new(access_token: access_token || ENV['GITHUB_TOKEN'])
    end

    def create_release(tag, options = {})
      options[:name] = "Release #{tag}" unless options.key?(:name)
      options[:target_commitish] = commit_sha unless options.key?(:target_commitish)

      begin
        @client.create_release(@repo, tag, options) if target_commitish_exist?(options[:target_commitish])
      rescue Octokit::UnprocessableEntity
        puts "Release already exists!"
        exit
      else
        puts "Successfully released"
      end
    end

    def create_update_pr(title, body, base = 'master', head = 'develop')
      if issue_num = get_pr(base, head, title)
        @client.update_pull_request(
          @repo,
          issue_num,
          title,
          body
        )
      else
        begin
          @client.create_pull_request(
            @repo,
            base,
            head,
            title,
            body
          )
        rescue Octokit::UnprocessableEntity
          puts 'Pull request unnecessary'
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
          state: 'open',
        )

        prs.each do |pr|
          return pr.number if pr.title == title
        end
      rescue Octokit::NotFound
      end
      return false
    end

    def target_commitish_exist?(sha)
      begin
        @client.commit(@repo, sha)
      rescue Octokit::NotFound
        puts "target_commitsh: #{sha} not on remote"
        return false
      end
    end
  end
end
