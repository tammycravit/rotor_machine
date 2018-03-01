require 'simplecov'
SimpleCov.start do
  add_group "Library", "lib"
  add_group "Tests",   "spec"
end

require "bundler/setup"
require "rotor_machine"
require "fileutils"
require 'tcravit_ruby_lib'
require 'pry'

Dir["./spec/support/**/*.rb"].each {|f| require f}

# A quick-and-dirty method to load RSpec helper files in spec/support
def require_helper_named(helper_name)
  require "#{File.join(File.dirname(__FILE__), "support", "#{helper_name}.rb")}"
end

# A quick-and-dirty method to load RSpec matchers in spec/support/matchers
def require_custom_matcher_named(matcher_name)
  require "#{File.join(File.dirname(__FILE__), "support", "matchers", "#{matcher_name}_matcher.rb")}"
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Captures the output for analysis later end @example Capture `$stderr`
  #
  #     output = capture(:stderr) { $stderr.puts "this is captured" }
  #
  # @param [Symbol] stream `:stdout` or `:stderr` @yield The block to capture stdout/stderr for. @return [String] The contents of $stdout or 
  # $stderr
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end

  # Silences the output stream
  #
  # @example Silence `$stdout`
  #
  #     silence(:stdout) { $stdout.puts "hi" }
  #
  # @param [IO] stream The stream to use such as $stderr or $stdout @return [nil]
  alias :silence :capture
end
