$:.unshift File.dirname(__FILE__)

require "rotor_machine/version"

Dir[File.join(File.dirname(__FILE__), "rotor_machine", "*.rb")].reject { |x| File.basename(x) == "version.rb" }.each do |f|
  require File.join("rotor_machine", File.basename(f)) 
end

module RotorMachine
  # Your code goes here...
end
