# frozen_string_literal: true

# Used constants:
# - BUILD_DIR

require 'json'

namespace :release do
  desc 'Create a new release'
  task :new => [:check_versions, :check_tag_and_ask_to_release, 'spm:test', :github, :cocoapods]

  desc 'Check if all versions from the podspecs and CHANGELOG match'
  task :check_versions do
    results = []

    Utils.table_header('Check', 'Status')

    # Check if bundler is installed first, as we'll need it for the cocoapods task (and we prefer to fail early)
    `which bundler`
    results << Utils.table_result(
      $CHILD_STATUS.success?,
      'Bundler installed',
      'Install bundler using `gem install bundler` and run `bundle install` first.'
    )

    # Extract version from podspec
    podspec = Utils::podspec(POD_NAME)
    v = podspec['version']
    Utils.table_info("#{POD_NAME}.podspec", v)

    # Check podspec tag
    podspec_tag = podspec['source']['tag']
    results << Utils.table_result(podspec_tag == v, 'Podspec version & tag equal', 'Update the `tag` in podspec')

    # Check docs config
    docs_version = Utils.first_match_in_file('docs/conf.py', /version = '(.+)'/, 1)
    docs_release = Utils.first_match_in_file('docs/conf.py', /release = '(.+)'/, 1)
    results << Utils.table_result(docs_version == v,'Docs, version updated', 'Update the `version` in docs/conf.py')
    results << Utils.table_result(docs_release == v, 'Docs, release updated', 'Update the `release` in docs/conf.py')

    # Check docs installation
    docs_package = Utils.first_match_in_file('docs/installation.rst', /\.package\(url: .+ from: "(.+)"/, 1)
    docs_cocoapods = Utils.first_match_in_file('docs/installation.rst', /pod 'Stencil', '~> (.+)'/, 1)
    docs_carthage = Utils.first_match_in_file('docs/installation.rst', /github ".+\/Stencil" ~> (.+)/, 1)
    results << Utils.table_result(docs_package == v, 'Docs, package updated', 'Update the package version in docs/installation.rst')
    results << Utils.table_result(docs_cocoapods == v, 'Docs, cocoapods updated', 'Update the cocoapods version in docs/installation.rst')
    results << Utils.table_result(docs_carthage == v, 'Docs, carthage updated', 'Update the carthage version in docs/installation.rst')

    # Check if entry present in CHANGELOG
    changelog_entry = Utils.first_match_in_file('CHANGELOG.md', /^## #{Regexp.quote(v)}$/)
    results << Utils.table_result(changelog_entry, 'CHANGELOG, Entry added', "Add an entry for #{v} in CHANGELOG.md")

    changelog_has_stable = system("grep -qi '^## Master' CHANGELOG.md")
    results << Utils.table_result(!changelog_has_stable, 'CHANGELOG, No master', 'Remove section for master branch in CHANGELOG')

    exit 1 unless results.all?
  end

  desc "Check tag and ask to release"
  task :check_tag_and_ask_to_release do
    results = []
    podspec_version = Utils.podspec_version(POD_NAME)

    tag_set = !`git ls-remote --tags . refs/tags/#{podspec_version}`.empty?
    results << Utils.table_result(
      tag_set,
      'Tag pushed',
      'Please create a tag and push it'
    )

    exit 1 unless results.all?

    print "Release version #{podspec_version} [Y/n]? "
    exit 2 unless STDIN.gets.chomp == 'Y'
  end

  desc "Create a new GitHub release"
  task :github do
    require 'octokit'

    client = Utils.octokit_client
    tag = Utils.top_changelog_version
    body = Utils.top_changelog_entry

    raise 'Must be a valid version' if tag == 'Master'

    repo_name = File.basename(`git remote get-url origin`.chomp, '.git').freeze
    puts "Pushing release notes for tag #{tag}"
    client.create_release("stencilproject/#{repo_name}", tag, name: tag, body: body)
  end

  desc "pod trunk push #{POD_NAME} to CocoaPods"
  task :cocoapods do
    Utils.print_header 'Pushing pod to CocoaPods Trunk'
    sh "bundle exec pod trunk push #{POD_NAME}.podspec.json"
  end
end
