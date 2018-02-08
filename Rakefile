require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "tcravit_ruby_lib/rake_tasks"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :release => :version_bump

task :version_bump => [:spec, :version:bump:build] do
  if (system("git add lib/rotor_machine/version.rb")) 
    unless (system("git commit -m 'version bump'"))
      abort("Could not commit new version.rb")
    end
  end
end
