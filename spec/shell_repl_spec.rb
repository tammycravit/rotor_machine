############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : shell_repl_spec.rb
# Specs for   : The REPL interface of the RotorMachine::Shell class.
############################################################################
#  Copyright 2018, Tammy Cravit.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
############################################################################

require 'rspec'
require 'spec_helper'
require 'rotor_machine'

# Extensions to the String class to make testing a bit easier..
require_helper_named('string_extensions')

# Custom matcher to check rotor state
require_custom_matcher_named("rotor_state")
require_custom_matcher_named("reflector_state")

RSpec.describe "RotorMachine::Shell" do
  context "REPL Interface" do
    it "should allow the REPL to be launched from the class helper method" do
      expect{ RotorMachine::Shell.repl(["version"]) }.to output(RotorMachine::Shell.new().banner).to_stdout()
    end

    it "should display the app banner" do
      expect{ RotorMachine::Shell.new().repl(["version"]) }.to output(RotorMachine::Shell.new().banner).to_stdout()
    end

    it "should display the last encryption result" do
      expect{ RotorMachine::Shell.new().repl(["encipher THIS IS A TEST", "last_result"]) }.to output(/QCTBG IJSWI H/).to_stdout()
    end

    it "should encipher text when asked" do
      expect{ RotorMachine::Shell.new().repl(["encipher THIS IS A TEST"]) }.to output(/QCTBG IJSWI H/).to_stdout()
    end

    it "should display an error message when an invalid command is entered" do
      expect{ RotorMachine::Shell.new().repl(["invalid"]) }.to output(/Unknown command: invalid/).to_stdout()
    end

    it "should display an error when a command has the wrong arity" do
      expect{ RotorMachine::Shell.new().repl(["rotor"]) }.to output(/rotor requires at least 1 arguments/).to_stdout()
    end

    it "should display an error when a command raises an exception" do
      expect{ RotorMachine::Shell.new().repl([" "]) }.to output(/Rescued exception: undefined method \`downcase\' for nil:NilClass/).to_stdout()
    end
  end
end
