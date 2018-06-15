require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "tcravit_ruby_lib/rake_tasks"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
require 'rake'

namespace :coverage do
  desc "Generate a contextual report from the SimpleCov output"
  task :resolve do
    project_root = File.expand_path(File.join(File.dirname(__FILE__)))
    system("#{project_root}/bin/resolve_coverage.pl #{project_root}/coverage/coverage.txt")
  end
end

