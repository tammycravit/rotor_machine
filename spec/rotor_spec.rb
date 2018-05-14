############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor machine.
#
# File        : rotor_spec.rb
# Specs for   : A rotor, the central (movable) encryption component of the
#               Enigma machine.
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

require_custom_matcher_named "rotor_state"

RSpec.describe "RotorMachine::Rotor" do
  
  before(:each) do
    @rotor = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, 'K')
  end

  context "setup" do
    it "should allow you to create a rotor with a type" do
      rotor = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I)
      expect(rotor).to have_rotor_state(kind: :ROTOR_I, position: 0, letter: "J", step_size: 1)
    end

    it "should allow you to create a rotor with a type and numeric position" do
      rotor = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, 12)
      expect(rotor).to have_rotor_state(kind: :ROTOR_I, position: 12, letter: "F", step_size: 1)
    end

    it "should allow you to create a rotor with a type and character position" do
      rotor = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, "F")
      expect(rotor).to have_rotor_state(kind: :ROTOR_I, position: 12, letter: "F", step_size: 1)
    end

    it "should allow you to create a rotor with a type, numeric position, and stepping" do
      rotor = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, 12, 3)
      expect(rotor).to have_rotor_state(kind: :ROTOR_I, position: 12, letter: "F", step_size: 3)
    end

    it "should allow you to create a rotor with a type, character position, and stepping" do
      rotor = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, "F", 3)
      expect(rotor).to have_rotor_state(kind: :ROTOR_I, position: 12, letter: "F", step_size: 3)
    end

    it "should raise an exception if you try to create a rotor with no type" do
      expect{RotorMachine::Rotor.new()}.to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 1..3)")
    end

    it "should raise an exception if you try to create a rotor with duplicate characters" do
      expect {RotorMachine::Rotor.new("ABCDEFGHIJKLMNOPQRSTUVWXYY")}.to raise_error(ArgumentError, "Initialization string contains duplicate letters")
    end
  end

  context "preliminaries" do
    it "should define constants for the standard Enigma rotors" do
      ["IC", "IIC", "IIIC", "I", "II", "III", "UKW", "ETW"].each do |rk|
        expect(@rotor.class).to be_const_defined("ROTOR_#{rk}")
      end
    end

    it "should be able to describe itself" do
      expect(@rotor.to_s).to be == "a RotorMachine::Rotor of type 'ROTOR_I', position=20 (K), step_size=1"
    end
  end

  context "rotor positioning" do
    it "should know what its current position is" do
      expect(@rotor).to respond_to(:position)
      expect(@rotor.position).to be == 20
    end

    it "should allow you to set its current position numerically" do
      @rotor.position = 14
      expect(@rotor.position).to be == 14
    end

    it "should allow you to set its current position alphabetically" do
      @rotor.position = "Q"
      expect(@rotor.position).to be == 3
    end

    it "should know the letter of the current position" do
      @rotor.position = "Q"
      expect(@rotor.current_letter).to be == "Q"
    end
  end

  context "rotor stepping" do
    it "should allow you to step the rotor" do
      @rotor.position = 0
      @rotor.step
      expect(@rotor.position).to be == 1
    end

    it "should wrap the position in a circular manner" do
      @rotor.position = 25
      @rotor.step
      expect(@rotor.position).to be == 0
    end

    it "should know if the rotor wrapped on the last step" do
      @rotor.position = 25
      @rotor.step
      expect(@rotor.wrapped?).to be_truthy
      @rotor.step
      expect(@rotor.wrapped?).not_to be_truthy
    end

    it "should allow you to step the rotor by a different amount" do
      @rotor.position = 0
      @rotor.step 2
      expect(@rotor.position).to be == 2
    end

    it "should wrap the rotor position correctly for a non-standard stepping amount" do
      @rotor.position = 25
      @rotor.step(2)
      expect(@rotor.position).to be == 1
    end

    it "should allow the rotor to have an arbitrary stepping value" do
      @rotor.step_size = 2
      @rotor.position = 2
      @rotor.step
      expect(@rotor.position).to be == 4
    end
  end

  context "basic operation" do
    it "should allow you to encipher a letter" do
      expect(@rotor.forward("C")).to be == "L"
    end

    it "should allow you to encipher in both directions" do
      expect(@rotor.reverse("L")).to be == "C"
    end

    it "should have symmetric forward and reverse transformations" do
      RotorMachine::Rotor::ALPHABET.chars.each { |c| expect(@rotor.reverse(@rotor.forward(c))).to be == c }
    end

    it "should pass-through non-alphabetic characters unchanged" do
      "1234567890!@^&*()".chars.each { |c| expect(@rotor.forward(c)).to be == c }
      "1234567890!@^&*()".chars.each { |c| expect(@rotor.reverse(c)).to be == c }
    end
  end

  context "error handling - rotor position" do
    it "should raise an error if set to an invalid numeric position" do
      expect{@rotor.position = -10}.to raise_error(ArgumentError, "Position -10 is invalid")
      expect{@rotor.position = 49}.to raise_error(ArgumentError, "Position 49 is invalid")
    end

    it "should raise an error if set to an invalid character" do
      expect{@rotor.position = '%'}.to raise_error(ArgumentError, "% is not a character on the rotor")
    end

    it "should raise an error if an invalid argument type is passed to position=" do
      expect{@rotor.position = []}.to raise_error(ArgumentError, "Invalid argument to position= (Array)") 
    end
  end

  context "miscellaneous functions" do
    it "should be able to compare itself to another rotor" do
      one   = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, 0, 1)
      two   = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, 0, 1)
      three = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_II, 0, 1)
      four  = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, 8, 1)
      five  = RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, 0, 3)

      expect(one).to       be == two
      expect(two).to       be == one
      expect(three).not_to be == one
      expect(four).not_to  be == one
      expect(five).not_to  be == one
    end
  end

end
