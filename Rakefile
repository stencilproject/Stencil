#!/usr/bin/rake

unless defined?(Bundler)
  puts 'Please use bundle exec to run the rake command'
  exit 1
end

require 'English'

## [ Constants ] ##############################################################

POD_NAME = 'Stencil'
MIN_XCODE_VERSION = 13.0
BUILD_DIR = File.absolute_path('./.build')

## [ Build Tasks ] ############################################################

namespace :files do
  desc 'Update all files containing a version'
  task :update, [:version] do |_, args|
    version = args[:version]

    Utils.print_header "Updating files for version #{version}"

    podspec = Utils.podspec(POD_NAME)
    podspec['version'] = version
    podspec['source']['tag'] = version
    File.write("#{POD_NAME}.podspec.json", JSON.pretty_generate(podspec) + "\n")

    replace('CHANGELOG.md', '## Master' => "\#\# #{version}")
    replace("docs/conf.py",
      /^version = .*/ => %Q(version = '#{version}'),
      /^release = .*/ => %Q(release = '#{version}')
    )
    docs_package = Utils.first_match_in_file('docs/installation.rst', /\.package\(url: .+ from: "(.+)"/, 1)
    replace("docs/installation.rst",
      /\.package\(url: .+, from: "(.+)"/ => %Q(.package\(url: "https://github.com/stencilproject/Stencil.git", from: "#{version}"),
      /pod 'Stencil', '.*'/ => %Q(pod 'Stencil', '~> #{version}'),
      /github "stencilproject\/Stencil" ~> .*/ => %Q(github "stencilproject/Stencil" ~> #{version})
    )
  end

  def replace(file, replacements)
    content = File.read(file)
    replacements.each do |match, replacement|
      content.gsub!(match, replacement)
    end
    File.write(file, content)
  end
end

task :default => 'release:new'
