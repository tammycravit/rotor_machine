############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : dsl_spec.rb
# Specs for   : The RotorMachine::Session class, which provides a DSL for
#               (interactively and programmatically) manipulating a
#               RotorMachine.
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
require 'pty'

# Extensions to the String class to make testing a bit easier..
require_helper_named('string_extensions')

# Custom matcher to check rotor state
require_custom_matcher_named("rotor_state")
require_custom_matcher_named("reflector_state")

RSpec.describe "RotorMachine::Shell" do
  before(:each) do
    @shell = RotorMachine::Shell.new()
    @shell.default_machine([])
  end

  context "the basics" do
    it "should have a RotorMachine::Machine instance" do
      expect(@shell).to be_a(RotorMachine::Shell)
      expect(@shell.the_machine).to be_a(RotorMachine::Machine)
    end
  end

  context "shell command methods" do
    context "rotor" do

      it "should define a 'rotor' verb" do
        expect(@shell).to respond_to(:rotor)
        res = @shell.rotor(["ROTOR_I", "0", "1"])

        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "Added rotor 4 of kind ROTOR_I"

        expect(@shell.the_machine.rotors.count).to be == 4
        expect(@shell.the_machine.rotors[3]).to have_rotor_state(kind: :ROTOR_I,
                                                                position: 0,
                                                                step_size: 1)
      end

      it "should default the optional arguments for the 'rotor' verb" do
        expect(@shell).to respond_to(:rotor)
        res = @shell.rotor(["ROTOR_I"])

        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "Added rotor 4 of kind ROTOR_I"

        expect(@shell.the_machine.rotors.count).to be == 4
        expect(@shell.the_machine.rotors[3]).to have_rotor_state(kind: :ROTOR_I,
                                                                position: 0,
                                                                step_size: 1)
      end

      it "should allow numeric arguments for the optional args" do
        expect(@shell).to respond_to(:rotor)
        res = @shell.rotor(["ROTOR_I", 0, 1])

        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "Added rotor 4 of kind ROTOR_I"

        expect(@shell.the_machine.rotors.count).to be == 4
        expect(@shell.the_machine.rotors[3]).to have_rotor_state(kind: :ROTOR_I,
                                                                position: 0,
                                                                step_size: 1)
      end

      it "should allow an alphabetic position argument" do
        expect(@shell).to respond_to(:rotor)
        res = @shell.rotor(["ROTOR_I", "P", 1])

        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "Added rotor 4 of kind ROTOR_I"

        expect(@shell.the_machine.rotors.count).to be == 4
        expect(@shell.the_machine.rotors[3]).to have_rotor_state(kind: :ROTOR_I,
                                                                letter: "P",
                                                                step_size: 1)
      end
    end

    context "reflector" do
      it "should define a 'reflector' verb" do
        args = ["REFLECTOR_A"]
        expect(@shell).to respond_to(:reflector)
        res = @shell.reflector(args)

        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "Set reflector of kind REFLECTOR_A"

        expect(@shell.the_machine.reflector).to have_reflector_state(kind: :REFLECTOR_A,
                                                                    position: 0)
      end

      it "should allow a position argument for the reflector verb" do
        args = ["REFLECTOR_A", "12"]
        expect(@shell).to respond_to(:reflector)
        res = @shell.reflector(args)

        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "Set reflector of kind REFLECTOR_A"

        expect(@shell.the_machine.reflector).to have_reflector_state(kind: :REFLECTOR_A,
                                                                    position: 12)
      end

      it "should allow a numeric argument for the reflector position arg" do
        args = ["REFLECTOR_A", 3]
        expect(@shell).to respond_to(:reflector)
        res = @shell.reflector(args)

        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "Set reflector of kind REFLECTOR_A"

        expect(@shell.the_machine.reflector).to have_reflector_state(kind: :REFLECTOR_A,
                                                                    position: 3)
      end

      it "should allow an alphabetic argument for the reflector position arg" do
        args = ["REFLECTOR_A", "D"]
        expect(@shell).to respond_to(:reflector)
        res = @shell.reflector(args)

        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "Set reflector of kind REFLECTOR_A"

        expect(@shell.the_machine.reflector).to have_reflector_state(kind: :REFLECTOR_A,
                                                                    letter: "D")
      end

    end

    it "should define a 'connect' verb" do
      args = ["A", "C"]
      expect(@shell).to respond_to(:connect)
      res = @shell.connect(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "Connected A to C on plugboard"

      expect(@shell.the_machine.plugboard.connections["A"]).to be == "C"
      expect(@shell.the_machine.plugboard.connections["C"]).to be == "A"
    end

    it "should define a 'disconnect' verb" do
      args = ["A", "C"]
      res = @shell.connect(args)

      args = ["A"]
      expect(@shell).to respond_to(:disconnect)
      res = @shell.disconnect(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "Disconnected A and its inverse on plugboard"

      expect(@shell.the_machine.plugboard.connections.keys).not_to include(:A)
      expect(@shell.the_machine.plugboard.connections.keys).not_to include(:C)
    end

    it "should define a 'default_machine' verb" do
      args = []
      expect(@shell).to respond_to(:default_machine)
      res = @shell.default_machine(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "Reset machine to default configuration"

      expect(@shell.the_machine).to be == RotorMachine::Factory.default_machine
    end

    it "should define a 'empty_machine' verb" do
      args = []
      expect(@shell).to respond_to(:empty_machine)
      res = @shell.empty_machine(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "Reset machine to empty configuration"

      expect(@shell.the_machine).to be == RotorMachine::Factory.empty_machine
    end

    it "should define a 'last_result' verb" do
      args = []
      @shell.encipher(["THIS IS A TEST"])
      expect(@shell).to respond_to(:last_result)
      res = @shell.last_result(args)

      expect(res).to be_a(String)
      expect(res).to be == "QCTBG IJSWI H"
    end

    it "should define a 'configuration' verb" do
      args = []
      expect(@shell).to respond_to(:configuration)
      res = @shell.configuration(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == @shell.the_machine.to_s
    end

    it "should define a 'set_positions' verb" do
      args = ["AAA"]
      expect(@shell).to respond_to(:set_positions)
      res = @shell.set_positions(args)
      expect(res).to be_a(String)

      expect(res).not_to be_nil
      expect(res).to be == "Set rotors; rotor state is now AAA"

      expect(@shell.the_machine.rotors[0]).to have_rotor_state(letter: "A")
      expect(@shell.the_machine.rotors[1]).to have_rotor_state(letter: "A")
      expect(@shell.the_machine.rotors[2]).to have_rotor_state(letter: "A")
    end

    it "should define a 'clear_rotors' verb" do
      args = []
      expect(@shell).to respond_to(:clear_rotors)
      res = @shell.clear_rotors(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "Removed all rotors from the machine"

      expect(@shell.the_machine.rotors.count).to be == 0
    end

    it "should define a 'clear_plugboard' verb" do
      args = ["A", "C"]
      res = @shell.connect(args)

      args = []
      expect(@shell).to respond_to(:clear_plugboard)
      res = @shell.clear_plugboard(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "Removed all connections from the plugboard"

      expect(@shell.the_machine.plugboard.connections.count).to be == 0
    end
  end

  context "encipherment operations" do
    it "should join the arguments when an array is passed in" do
      args = ["THIS", " IS A", " TEST"]
      expect(@shell).to respond_to(:encipher)
      res = @shell.encipher(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "QCTBG IJSWI H"
    end

    it "should define a 'encipher' verb" do
      args = "THIS IS A TEST"
      expect(@shell).to respond_to(:encipher)
      res = @shell.encipher(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "QCTBG IJSWI H"
    end

    it "should convert the argument to a string if necessary" do
      args = "THIS IS A TEST".to_sym
      expect(@shell).to respond_to(:encipher)
      res = @shell.encipher(args)

      expect(res).to be_a(String)
      expect(res).not_to be_nil
      expect(res).to be == "QCTBG IJSWI H"
    end

    it "should return an empty string when encipher is called with a nil argument" do
      args = nil
      expect(@shell).to respond_to(:encipher)
      res = @shell.encipher(args)

      expect(res).to be_a(String)
      expect(res).to be_empty
    end
  end

  context "metadata" do
    context "#help" do
      it "should return help text for help with no arguments" do
        args = []
        expect(@shell).to respond_to(:help)
        res = @shell.help(args)

        expect(res).to be_a(String)
        expect(res).not_to be_empty

        lines = res.split("\n")
        expect(lines.count).to be == @shell.verbs.keys.count + 1
        expect(lines[1]).to be == "about_prompt         Information about the shell prompt"
        expect(lines[(lines.count - 1)]).to be == "version              Display the version of the rotor_machine library"
      end

      it "should return help text for a specific command" do
        args = ["version"]
        expect(@shell).to respond_to(:help)
        res = @shell.help(args)

        expect(res).to be_a(String)
        expect(res).not_to be_empty

        lines = res.split("\n")
        expect(lines[1].strip).to be == "version: Display the version of the rotor_machine library"
        expect(lines[2].strip).to be == ""
        expect(lines[3].strip).to be == "Usage  : version"
        expect(lines[4].strip).to be == "Aliases: none"
      end

      it "should raise an exception if help is requested for an nonexistent verb" do
        args = ["fdjahfjahafsdkhf"]

        expect(@shell).to respond_to(:help)
        expect { @shell.help(args) }.to raise_exception(NoMethodError)
      end
    end

    context "#version" do
      it "should return a version string when asked" do
        expect(@shell).to respond_to(:version)
        res = @shell.version([])
        expect(res).to be_a(String)
        expect(res).not_to be_nil
        expect(res).to be == "rotor_machine version #{RotorMachine::VERSION}"
      end
    end
  end

  context "internal shell helpers" do
    context "#rotor_state" do
      it "should return the state of all the rotors" do
        @shell.set_positions(["ABC"])
        expect(@shell).to respond_to("rotor_state")
        expect(@shell.rotor_state).to be_a(String)
        expect(@shell.rotor_state).not_to be_nil
        expect(@shell.rotor_state).to be == "ABC"
        expect(@shell.the_machine.rotors[0]).to have_rotor_state(letter: "A")
        expect(@shell.the_machine.rotors[1]).to have_rotor_state(letter: "B")
        expect(@shell.the_machine.rotors[2]).to have_rotor_state(letter: "C")
      end
    end

    context "#is_internal_verb?" do
      it "should return true for an internal verb" do
        expect(@shell.is_internal_verb?(:rotor)).to be_truthy
      end

      it "should return true for an alias of an internal verb" do
        expect(@shell.is_internal_verb?(:config)).to be_truthy
      end

      it "should return false for an external verb" do
        expect(@shell.is_internal_verb?(:quit)).not_to be_truthy
      end

      it "should return false for a nonexistent verb" do
        expect(@shell.is_internal_verb?(:nonexistent)).not_to be_truthy
      end
    end

    context "#arity" do
      it "should return the correct arity for an internal command" do
        expect(@shell.arity(:rotor)).to be == 1
      end

      it "should return the correct arity for an external command" do
        expect(@shell.arity(:set_rotors)).to be == 1
      end

      it "should return 0 for a nonexistent command" do
        expect(@shell.arity(:nonexistent)).to be == 0
      end
    end

    context "#verbs" do
      it "should return a list of the verbs defined by the shell" do
        v = @shell.verbs
        expect(v).to be_a(Hash)
        v.each do |verb_name, verb_definition|
          expect(verb_name).not_to be_nil
          expect(verb_definition).not_to be_nil

          expect(verb_name).to be_a(Symbol)
          expect(verb_definition).to be_an(Array)
          expect(verb_definition.length).to be == 3
          expect(verb_definition[0]).to be_a(String)
          expect(verb_definition[0]).not_to be_nil
          unless verb_definition[1].nil?
            expect(verb_definition[1]).to be_a(String)
          end
          unless verb_definition[2].nil?
            expect(verb_definition[2]).to be_a(String)
          end
        end
      end
    end
  end

  context "shell REPL" do
    before(:all) do
  #     @output, @input = PTY.spawn("exe/rotor_machine")
    end
  end
end
