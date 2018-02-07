############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor machine.
#
# File        : plugboard_spec.rb
# Specs for   : The "plugboard", which provides configurable letter 
#               substitutions before letters enter the rotor/reflector
#               assembly.
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

RSpec.describe "RotorMachine::Plugboard" do

  context "normal operation" do

    before(:each) do
      @plugboard = RotorMachine::Plugboard.new()
      @plugboard.connect 'A', 'B'
    end

    it "allows you to connect pairs of letters for transposition" do
      expect(@plugboard.transpose('A')).to be == "B"
      expect(@plugboard.connected?('A')).to be_truthy
    end

    it "allows multi-character strings to be transposed" do
      expect(@plugboard.transpose('ACDEF')).to be == "BCDEF"
    end
    
    it "transposes letters symmetrically" do
      expect(@plugboard.transpose('QWERTYABQWERTY')).to be == "QWERTYBAQWERTY"
      expect(@plugboard.connected?('A')).to be_truthy
      expect(@plugboard.connected?('B')).to be_truthy
    end
    
    it "allows you to disconnect a letter" do
      expect(@plugboard.transpose('ABCDEF')).to be == "BACDEF"
      @plugboard.disconnect('A')
      expect(@plugboard.transpose('ABCDEF')).to be == "ABCDEF"
    end

    it "should allow you to disconnect either end of a plug" do
      @plugboard.disconnect('B')
      expect(@plugboard.transpose('ABCDEF')).to be == "ABCDEF"
    end

    it "should allow you to ask if a given letter is connected" do
      expect(@plugboard.connected?("A")).to be_truthy
      expect(@plugboard.connected?("Z")).not_to be_truthy
    end
  end

  context "error handling" do
    before(:each) do
      @plugboard = RotorMachine::Plugboard.new()
      @plugboard.connect("A", "B")
    end

    it "shouldn't allow the same letter to be connected twice" do
      expect { @plugboard.connect("A", "F")}.to raise_error(ArgumentError, "A is already connected")
      expect { @plugboard.connect("Q", "B")}.to raise_error(ArgumentError, "B is already connected")
      @plugboard.disconnect("A")
      expect { @plugboard.connect("A", "F")}.not_to raise_error
      expect { @plugboard.connect("B", "Q")}.not_to raise_error
    end

    it "shouldn't allow a letter to be connected to itself" do
      expect {@plugboard.connect("D", "D")}.to raise_error(ArgumentError, "D cannot be connected to itself")
    end

    it "shouldn't allow you to disconnect a letter that's not connected" do
      expect{@plugboard.disconnect('X')}.to raise_error(ArgumentError, 'X is not connected')
    end
  end
end
