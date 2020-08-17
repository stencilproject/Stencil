require 'json'

def current_pod_version
  JSON.parse(File.read(PODSPEC_FILE))['version']
end

namespace :pod do
  # rake pod:lint
  desc "Lint the podspec"
  task :lint do
    header "Linting podspec"
    sh("pod", "lib", "lint", PODSPEC_FILE)
  end

  # rake pod:push
  desc "Push the podspec to trunk"
  task :push do
    header "Pushing podspec to trunk"
    sh("pod", "trunk", "push", PODSPEC_FILE)
  end
end
