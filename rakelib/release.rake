require 'json'

namespace :release do

  # rake release:new
  desc "Ask for a version number and prepare a release PR for that version"
  task :new do
    info "Current version is: #{current_pod_version}"
    print "What version do you want to release? "
    new_version = STDIN.gets.chomp

    Rake::Task['release:start'].invoke(new_version)
  end

  # rake release:start[version]
  desc "Start a release by creating a PR with the required changes to bump the version"
  task :start, [:version] => ['release:create_branch', 'release:update_files', 'pod:lint', 'release:push_branch', 'github:create_release_pr', 'github:pull_master']

  # rake release:finish[version]
  desc "Finish a release after the PR has been merged, by tagging master and pushing to trunk"
  task :finish => ['github:pull_master', 'github:tag', 'pod:push', 'github:create_release', 'changelog:reset']


  ### Helper tasks ###

  # rake release:create_branch[version]
  task :create_branch, [:version] do |_, args|
    branch = release_branch(args[:version])

    header "Creating release branch"
    sh("git", "checkout", "-b", branch)
  end

  # rake release:update_files[version]
  task :update_files, [:version] do |_, args|
    version = args[:version]

    header "Updating files for version #{version}"

    podspec = JSON.parse(File.read(PODSPEC_FILE))
    podspec['version'] = version
    podspec['source']['tag'] = version
    File.write(PODSPEC_FILE, JSON.pretty_generate(podspec) + "\n")

    replace(CHANGELOG_FILE, '## Master' => "\#\# #{version}")
    replace("docs/conf.py",
      /^version = .*/ => %Q(version = '#{version}'),
      /^release = .*/ => %Q(release = '#{version}')
    )
    replace("docs/installation.rst",
      /pod 'Stencil', '.*'/ => %Q(pod 'Stencil', '~> #{version}'),
      /github "stencilproject\/Stencil" ~> .*/ => %Q(github "stencilproject/Stencil" ~> #{version})
    )

    ## Commit Changes
    sh("git", "add", PODSPEC_FILE, CHANGELOG_FILE, "docs/*")
    sh("git", "commit", "-m", "Version #{version}")
  end

  # rake release:push_branch[version]
  task :push_branch, [:version] do |_, args|
    branch = release_branch(args[:version])

    header "Pushing #{branch} to origin"
    sh("git", "push", "-u", "origin", branch)
  end
end
