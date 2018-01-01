# CookbookRelease

This gem assists with releasing chef cookbooks by providing a few rake tasks.

## Tasks

```
rake berkshelf:setup       # Setup berkshelf using env variables
rake changelog:next        # Changelog for next version only
rake changelog:update      # Update changelog
rake release:chef_server   # Chef server release
rake release:github        # Github release
rake release:supermarket   # Chef supermarket release
rake stove:setup           # Setup stove using env variables
rake version_pull_request  # Create/Update github release pull request
```

## Usage

In your Rakefile, add:

```
require "cookbook_release"

CookbookRelease::RakeTasks.new(10).create_tasks!
```
Where `10` is the major version of the cookbook.

Replace the `version` line in your metadata.rb file:

```
version_file = File.join(File.dirname(__FILE__), 'VERSION')
version File.exist?(version_file) ? IO.read(version_file) : '0.0.0'
```
This will look for a version file (VERSION). If it doesn't exist, it will use the default version number (0.0.0).

Update the .gitignore file:

```
VERSION
```
