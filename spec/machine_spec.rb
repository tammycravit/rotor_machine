############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : machine_spec.rb
# Specs for   : The "machine deck", which brings together a collection of
#               rotors, a plugboard, and a reflector and provides a
#               complete @machine.
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

RSpec.describe "RotorMachine::Machine" do
  context "normal machine setup" do
    before(:each) do
      @machine = RotorMachine::Machine.new()
      @machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, "A", 1)
      @machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_II, "A", 1)
      @machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_III, "A", 1)
      @machine.reflector = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
      @machine.plugboard = RotorMachine::Plugboard.new()
      @machine.plugboard.connect("A", "F")
      @machine.plugboard.connect("C", "D")
    end

    it "should allow manual setup of the machine" do
      expect(@machine.rotors.class.name).to be == "Array"
      expect(@machine.rotors.length).to be == 3
      @machine.rotors.each do |r| 
        expect(r).not_to be_nil
        expect(r.class.name).to be == "RotorMachine::Rotor"
      end

      expect(@machine.reflector).not_to be_nil
      expect(@machine.reflector.class.name).to be == "RotorMachine::Reflector"

      expect(@machine.plugboard).not_to be_nil
      expect(@machine.plugboard.class.name).to be == "RotorMachine::Plugboard"
    end

    it "should allow you to set the rotor positions as a group" do
      @machine.set_rotors("ABC")
      expect(@machine.rotors[0].current_letter).to be == "A"
      expect(@machine.rotors[1].current_letter).to be == "B"
      expect(@machine.rotors[2].current_letter).to be == "C"
    end

    it "should know how to describe itself" do
      m = RotorMachine::Machine.default_machine
      m.plugboard.connect("A", "C")
      info = m.to_s.split("\n")
      expect(info[0]).to be == "a RotorMachine::Machine with the following configuration:"
      expect(info[1]).to be == "  Rotors: 3"
      expect(info[2]).to be == "    - a RotorMachine::Rotor of type 'ROTOR_I', position=9 (A), step_size=1"
      expect(info[3]).to be == "    - a RotorMachine::Rotor of type 'ROTOR_II', position=18 (A), step_size=1"
      expect(info[4]).to be == "    - a RotorMachine::Rotor of type 'ROTOR_III', position=10 (A), step_size=1"
      expect(info[5]).to be == "  Reflector: a RotorMachine::Reflector of type 'REFLECTOR_A'"
      expect(info[6]).to be == "  Plugboard: a RotorMachine::Plugboard with connections: {\"A\"=>\"C\", \"C\"=>\"A\"}"
    end
  end

  context "machine stepping" do
    before(:each) do
      @machine = RotorMachine::Machine.default_machine()
      @machine.plugboard.connect("A", "F")
      @machine.plugboard.connect("C", "D")
    end

    it "should step the second rotor by one position when the third rotor wraps around" do
      @machine.rotors[1].position = 18
      @machine.rotors[2].position = 25
      @machine.step_rotors
      expect(@machine.rotors[2].position).to be == 0
      expect(@machine.rotors[1].position).to be == 19
    end

    it "should step the first rotor by one position when the second rotor wraps around" do
      @machine.rotors[2].position = 25
      @machine.rotors[1].position = 25
      curr_r1_p = @machine.rotors[0].position
      @machine.step_rotors
      expect(@machine.rotors[2].position).to be == 0
      expect(@machine.rotors[1].position).to be == 0
      expect(@machine.rotors[0].position).to be == (curr_r1_p + 1)
    end
  end

  context "encryption" do
    before(:each) do
      @machine = RotorMachine::Machine.default_machine()
      @machine.plugboard.connect("A", "F")
      @machine.plugboard.connect("C", "D")
      
      @plaintext = "THE QUICK BROWN FOX SAYS HI".freeze
    end

    it "should allow you to encrypt text" do
      @machine.set_rotors("ABC")
      ciphertext = @machine.encipher(@plaintext)
      expect(ciphertext).not_to be == @plaintext
    end

    it "should allow you to decrypt text by re-encrypting it a second time" do
      @machine.set_rotors("ABC")
      ciphertext = @machine.encipher(@plaintext)
      expect(ciphertext).not_to be == @plaintext
      @machine.set_rotors("ABC")
      new_plaintext = @machine.encipher(ciphertext)
      expect(new_plaintext).to be == @plaintext
    end

    it "should never encrypt a letter to itself" do
      @machine.rotors.each { |r| r.position = 0 }
      plaintext = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" * 100
      ciphertext = @machine.encipher(plaintext)
      plaintext = plaintext.chars
      ciphertext.chars.each_with_index do |c, i|
        expect(plaintext[i]).not_to be == c
      end
    end
  end

  context "machine setup via factory method" do
    it "should provide a default machine via the #default_machine class method" do
      machine = RotorMachine::Machine.default_machine

      expect(machine.rotors.class.name).to be == "Array"
      expect(machine.rotors.length).to be == 3
      machine.rotors.each do |r| 
        expect(r).not_to be_nil
        expect(r.class.name).to be == "RotorMachine::Rotor"
      end

      expect(machine.reflector).not_to be_nil
      expect(machine.reflector.class.name).to be == "RotorMachine::Reflector"

      expect(machine.plugboard).not_to be_nil
    end

    it "should provide a machine with no rotors or reflector via the #empty_machine class method" do
      machine = RotorMachine::Machine.empty_machine
      expect(machine.rotors.class.name).to be == "Array"
      expect(machine.rotors.length).to be == 0
      expect(machine.reflector).to be_nil
      expect(machine.plugboard).not_to be_nil
    end

    it "should raise an exception if you try to encrypt without loading rotors" do
      machine = RotorMachine::Machine.empty_machine
      machine.reflector = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
      expect { machine.encipher("THIS IS A TEST") }.to raise_error(ArgumentError, "Cannot encipher; no rotors loaded")
    end

    it "should raise an exception if you try to encrypt without loading a reflector" do
      machine = RotorMachine::Machine.empty_machine
      machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, "A", 1)
      machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_II, "A", 1)
      machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_III, "A", 1)
      expect { machine.encipher("THIS IS A TEST") }.to raise_error(ArgumentError, "Cannot encipher; no reflector loaded")
    end
  end

  context "utility functions" do
    it "should allow reformatting output to 5-letter blocks" do
      expect(RotorMachine::Machine.letter_blocks("THIS IS A TEST", 5)).to be == "THISI SATES T"
    end
  end
end
