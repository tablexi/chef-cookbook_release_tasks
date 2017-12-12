module CookbookReleaseTasks
  class SemVer
    def initialize(version_major)
      @version_major = version_major
    end

    def git_number
      "v#{number}"
    end

    def number
      "#{major}.#{minor}.#{patch}"
    end

    private

    def major
      @version_major
    end

    def minor
      ENV['VERSION_MINOR'] || 0
    end

    def patch
      ENV['VERSION_PATCH'] || 0
    end
  end
end
