# frozen_string_literal: true

# Used constants:
# _none_

namespace :spm do
  desc 'Build using SPM'
  task :build do |task|
    Utils.print_header 'Compile using SPM'
    Utils.run('swift build', task, xcrun: true)
  end

  desc 'Run SPM Unit Tests'
  task :test => :build do |task|
    Utils.print_header 'Run the unit tests using SPM'
    Utils.run('swift test --parallel', task, xcrun: true)
  end
end
