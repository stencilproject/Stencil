NEW_CHANGELOG_SECTION = "## Master\n" + ['Breaking', 'Enhancements', 'Deprecations', 'Bug Fixes', 'Internal Changes'].map do |s|
  <<~MARKDOWN

    ### #{s}
    
    _None_
  MARKDOWN
end.join

def changelog_first_section
  content = []
  section_count = 0
  File.foreach(CHANGELOG_FILE) do |line|
    section_count += 1 if line.start_with?('## ')
    break if section_count > 1
    content.append(line) if section_count == 1
  end
  content[1..].join
end

namespace :changelog do
  # rake changelog:reset
  desc "Add a new empty section at the top of the changelog and git push it"
  task :reset do
    header "Reset CHANGELOG"
    content = File.read(CHANGELOG_FILE)
    new_content = NEW_CHANGELOG_SECTION + "\n" + content
    File.write(CHANGELOG_FILE, new_content)

    sh("git", "add", CHANGELOG_FILE)
    sh("git", "commit", "-m", "Reset CHANGELOG")
    sh("git", "push")
  end
end
