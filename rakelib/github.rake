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
  # rake github:create_release_pr[version]
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
    info "Pull request created: #{res['html_url']}"
  end

  # rake github:tag
  task :tag do
    tag = current_pod_version
    sh("git", "tag", tag)
    sh("git", "push", "origin", tag)
  end

  # rake github:create_release
  task :create_release do
    tag_name = current_pod_version
    title = tag_name
    body = changelog_first_section()
    res = github_client.create_release(repo_slug, tag_name, name: title, body: body)
    info "GitHub Release created: #{res['html_url']}"
  end

  # rake github:pull_master
  task :pull_master do
    sh("git", "switch", "master")
    sh("git", "pull")
  end
end
