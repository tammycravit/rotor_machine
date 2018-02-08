$:.unshift File.dirname(__FILE__)

require "rotor_machine/version"

Dir[File.join(File.dirname(__FILE__), "rotor_machine", "*.rb")].reject { |x| File.basename(x) == "version.rb" }.each do |f|
  require File.join("rotor_machine", File.basename(f)) 
end

##
# The RotorMachine gem is a relatively simple implementation of the German
# WWII "Enigma"-style of rotor-based encryption machine.
#
# I wrote RotorMachine primarily as an exercise in Test-Driven Development
# with RSpec. It is not intended to be efficient or performant, and I wasn't
# striving much for idiomatic conciseness. My aims were fairly modular code
# and a relatively complete RSpec test suite.
#
# The documentation for {RotorMachine::Machine} shows an example of how to
# use the module.
# 
#@author Tammy Cravit <tammycravit@me.com>
module RotorMachine
end
