# frozen_string_literal: true

# Used constants:
# - POD_NAME

namespace :pod do
  desc 'Lint the Pod'
  task :lint do |task|
    Utils.print_header 'Linting the pod spec'
    Utils.run(%(bundle exec pod lib lint "#{POD_NAME}.podspec.json" --quick), task)
  end
end
