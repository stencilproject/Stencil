
require 'json'
require 'cgi'

### Helpers ###

PODSPEC_FILE = 'Stencil.podspec.json'

def header(title)
  line = "==> #{title}..."
  if `tput colors`.chomp.to_i >= 8
    puts "\e[1;32m" + line + "\e[0m"
  else
    puts line
  end
end

def release_branch(version)
  "release/#{version}"
end

def replace(file, replacements)
  content = File.read(file)
  replacements.each do |match, replacement|
    content.gsub!(match, replacement)
  end
  File.write(file, content)
end

### TASKS ###

### rake lint ###
task :lint do
  header "Linting podspec"
  sh("pod", "lib", "lint", PODSPEC_FILE)
end

namespace :release do

  ### rake release:new ###
  desc "Ask for a version number and prepare a release PR for that version"
  task :new do
    current_version = JSON.parse(File.read(PODSPEC_FILE))['version']
    puts "Current version is: #{current_version}"
    print "What version do you want to release? "
    new_version = STDIN.gets.chomp

    # By way of dependencies, this will call:
    # create_branch => update_files => lint => open_pr
    Rake::Task['release:open_pr'].invoke(new_version)
  end

  ### rake release:create_branch[version] ###
  task :create_branch, [:version] do |_, args|
    sh("git", "checkout", "-b", release_branch(args[:version]))
  end

  ### rake release:update_files[version] ###
  task :update_files, [:version] => ['release:create_branch'] do |_, args|
    version = args[:version]
    header "Updating files for version #{version}"

    podspec = JSON.parse(File.read(PODSPEC_FILE))
    podspec['version'] = version
    podspec['source']['tag'] = version
    File.write(PODSPEC_FILE, JSON.pretty_generate(podspec))

    replace("CHANGELOG.md", '## Master' => "\#\# #{version}")
    replace("docs/conf.py",
      /^version = .*/ => %Q(version = '#{version}'),
      /^release = .*/ => %Q(release = '#{version}')
    )
    replace("docs/installation.rst",
      /pod 'Stencil', '.*'/ => %Q(pod 'Stencil', '~> #{version}'),
      /github "stencilproject\/Stencil" ~> .*/ => %Q(github "stencilproject/Stencil" ~> #{version})
    )

    ## Commit Changes
    sh("git", "add", PODSPEC_FILE, "CHANGELOG.md", "docs/*")
    sh("git", "commit", "-m", "Version #{version}")
  end

  ### rake release:open_pr[version] ###
  task :open_pr, [:version] => ['release:update_files', 'lint'] do |_, args|
    version = args[:version]
    branch = release_branch(version)

    header "Pushing #{branch} to origin"
    sh("git", "push", "-u", "origin", branch)

    url = `git remote get-url origin`.chomp.gsub('git@github.com:', 'https://github.com/').gsub(/\.git$/, '')
    body = <<~BODY
      This PR prepares release #{version}.
  
      Once the PR is merged into master:
      - Tag the commit on master
      - Run \`pod trunk push #{PODSPEC_FILE}\`
      - Reset the changelog with an empty entry
    BODY

    header "Opening PR"
    sh("open", "#{url}/compare/master...#{branch}?quick_pull=1&body=#{CGI.escape(body)}")
  end  
end
