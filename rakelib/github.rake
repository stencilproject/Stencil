require 'octokit'

def repo_slug
  url_parts = `git remote get-url origin`.chomp.split(%r{/|:})
  last_two_parts = url_parts[-2..-1].join('/')
  last_two_parts.gsub(/\.git$/, '')
end

def github_client
  Octokit::Client.new(:netrc => true)
end

namespace :github do
  ### rake github:release_pr[version] ###
  task :create_release_pr, [:version] do |_, args|
    version = args[:version]
    branch = release_branch(version)

    title = "Release #{version}"
    body = <<~BODY
      This PR prepares the release for version #{version}.
  
      Once the PR is merged into master, run `bundle exec rake release:finish` to tag and push to trunk.
    BODY

    header "Opening PR"
    res = github_client.create_pull_request(repo_slug, "master", branch, title, body)
    puts res
  end

  task :tag, [:version] do |_, args|
    tag = args[:version]
    sh("git", "tag", tag)
    sh("git", "push", origin, tag)
  end

  task :create_release, [:version] do |_, args|
    tag_name = args[:version]
    title = "Release #{args[:version]}"
    body = changelog_first_section()
    github_client.create_release(repo_slug, tag_name, name: title, body: body)
  end
end