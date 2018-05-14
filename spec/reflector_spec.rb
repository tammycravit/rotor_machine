############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor machine.
#
# File        : reflector_spec
# Specs for   : The reflector, a fixed rotor which directs letters back
#               through the rotors in reverse order. The reflector is what
#               makes the Enigma machine's encryption symmetrical.
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

require_custom_matcher_named('reflector_state')

RSpec.describe "RotorMachine::Reflector" do
  before(:each) do
    @reflector = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
  end

  context "the preliminaries" do
    it "should define constants for the standard Enigma reflectors" do
      [:REFLECTOR_A, :REFLECTOR_B, :REFLECTOR_C, :REFLECTOR_B_THIN, :REFLECTOR_C_THIN, :REFLECTOR_ETW].each do |r|
        expect(@reflector.class).to be_const_defined(r)
      end
    end
  end

  context "basic functionality" do
    it "should know what kind of reflector it is" do
      expect(@reflector).to have_reflector_state(kind: :REFLECTOR_A)
    end

    it "should know what its position is" do
      expect(@reflector).to have_reflector_state(position: 0)
    end

    it "should know what its current letter is" do
      expect(@reflector).to have_reflector_state(letter: RotorMachine::Reflector::REFLECTOR_A[0])
    end

    it "should be able to describe itself" do
      expect(@reflector.to_s).to be == "a RotorMachine::Reflector of type 'REFLECTOR_A'"
    end
  end

  context "repositioning" do
    it "should be able to be repositioned to a specific letter" do
      @reflector.position = "Q"
      expect(@reflector).to have_reflector_state(letter: "Q", position: RotorMachine::Reflector::REFLECTOR_A.index("Q"))
    end

    it "should be able to be repositioned to a specific numeric position" do
      @reflector.position = 11
      expect(@reflector).to have_reflector_state(letter: RotorMachine::Reflector::REFLECTOR_A[11], position: 11)
    end

    it "should not allow positioning to a letter not on the reflector" do
      expect {@reflector.position = "*"}.to raise_error(ArgumentError)
    end

    it "should not allow positioning to a numeric position not on the reflector" do
      expect {@reflector.position = -10}.to raise_error(ArgumentError)
      expect {@reflector.position = 45}.to raise_error(ArgumentError)
    end

    it "should raise an error when an invalid position type is specified" do
      expect {@reflector.position = false}.to raise_error(ArgumentError)
      expect {@reflector.position = nil}.to raise_error(ArgumentError)
    end

  end

  context "transposition" do
    it "should transpose a character" do
      expect(@reflector.reflect("A")).to be == "E"
    end

    it "should allow transposition of a multi-character string" do
      expect(@reflector.reflect("ABC")).to be == "EJM"
    end

    it "should pass through characters not defined by the reflector unchanged" do
      expect(@reflector.reflect("123ABC123")).to be == "123EJM123"
    end
  end

  context "miscellaneous functions" do
    it "should be able to compare itself to another reflector" do
      one = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A, 0)
      two = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A, 0)
      three = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_B, 0)
      four = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A, 17)

      expect(one).to be == two
      expect(two).to be == one
      expect(three).not_to be == one
      expect(four).not_to be == one
    end
  end
end
