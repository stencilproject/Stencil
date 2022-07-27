# frozen_string_literal: true

# Used constants:
# _none_

require_relative 'check_changelog'

namespace :changelog do
  desc 'Add the empty CHANGELOG entries after a new release'
  task :reset do
    changelog = File.read('CHANGELOG.md')
    abort('A Master entry already exists') if changelog =~ /^##\s*Master$/
    changelog.sub!(/^##[^#]/, "#{header}\\0")
    File.write('CHANGELOG.md', changelog)
  end

  def header
    <<-HEADER.gsub(/^\s*\|/, '')
      |## Master
      |
      |### Breaking
      |
      |_None_
      |
      |### Enhancements
      |
      |_None_
      |
      |### Deprecations
      |
      |_None_
      |
      |### Bug Fixes
      |
      |_None_
      |
      |### Internal Changes
      |
      |_None_
      |
    HEADER
  end

  desc 'Check if links to issues and PRs use matching numbers between text & link'
  task :check do
    warnings = check_changelog
    if warnings.empty?
      puts "\u{2705}  All entries seems OK (end with period + 2 spaces, correct links)"
    else
      puts "\u{274C}  Some warnings were found:\n" + Array(warnings.map do |warning|
        " - Line #{warning[:line]}: #{warning[:message]}"
      end).join("\n")
      exit 1
    end
  end
end
