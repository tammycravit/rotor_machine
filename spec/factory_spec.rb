############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : rotor_factory_spec.rb
# Specs for   : The rotor factory, which provides a simplified interface for
#               creating rotors and reflectors.
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

RSpec.describe "RotorMachine::Factory" do
  context "the preliminaries" do
    it "should provide factory method for building Enigma components" do
      expect(RotorMachine::Factory).to respond_to(:build_rotor)
      expect(RotorMachine::Factory).to respond_to(:build_reflector)
      expect(RotorMachine::Factory).to respond_to(:build_plugboard)
      expect(RotorMachine::Factory).to respond_to(:build_machine)
    end
  end

  context "#build_reflector" do
    context "specifying reflector alphabet" do
      it "should allow specifying of a reflector constant name" do
        expect {@r = RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A)}.not_to raise_exception
        expect(@r).to be_instance_of(RotorMachine::Reflector)
        expect(@r.reflector_kind_name).to be == :REFLECTOR_A
      end

      it "should allow specifying of a reflector alphabet" do
        expect {@r = RotorMachine::Factory.build_reflector(reflector_kind: "QWERTYUIOPASDFGHJKLZXCVBNM")}.not_to raise_exception
        expect(@r).to be_instance_of(RotorMachine::Reflector)
        expect(@r.reflector_kind_name).to be == :CUSTOM
      end

      it "should raise an error if the reflector constant name is not defined" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :UNDEFINED_ROTOR)}.to raise_exception(ArgumentError)
      end

      it "should raise an error if the reflector alphabet is the wrong length" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: "TOO SHORT")}.to raise_exception(ArgumentError)
        expect {RotorMachine::Factory.build_reflector(reflector_kind: "QWERTYUIOPASDFGHJKLZXCVBNMEXTRALETTERS")}.to raise_exception(ArgumentError)
      end
    end

    context "specifying initial position" do
      it "should allow specifying the initial position as a character" do
        expect {@r = RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A, initial_position: "A")}.not_to raise_exception
        expect(@r).to be_instance_of(RotorMachine::Reflector)
        expect(@r.current_letter).to be == "A"
      end

      it "should allow specifying the initial position as a number" do
        expect {@r = RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A, initial_position: 7)}.not_to raise_exception
        expect(@r).to be_instance_of(RotorMachine::Reflector)
        expect(@r.current_letter).to be == RotorMachine::Reflector::REFLECTOR_A[7]
        expect(@r.position).to be == 7
      end

      it "shoudl raise an error if the position letter is not present on the rotor" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A, initial_position: "*")}.to raise_error(ArgumentError)
      end

      it "should raise an error if the numeric position is out of range" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A, 
                                                  initial_position: -1)}.to raise_error(ArgumentError)
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A, 
                                                  initial_position: 38)}.to raise_error(ArgumentError)
      end
    end
  end

  context "#build_rotor" do
    context "specifying rotor alphabet" do
      it "should allow specifying of a rotor constant name" do
        expect {@r = RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I)}.not_to raise_exception
        expect(@r).to be_instance_of(RotorMachine::Rotor)
        expect(@r.rotor_kind_name).to be == :ROTOR_I
      end

      it "should allow specifying of a rotor alphabet" do
        expect {@r = RotorMachine::Factory.build_rotor(rotor_kind: "QWERTYUIOPASDFGHJKLZXCVBNM")}.not_to raise_exception
        expect(@r).to be_instance_of(RotorMachine::Rotor)
        expect(@r.rotor_kind_name).to be == :CUSTOM
      end

      it "should raise an error if the rotor constant name is not defined" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :UNDEFINED_ROTOR)}.to raise_exception(ArgumentError)
      end

      it "should raise an error if the rotor alphabet is the wrong length" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: "TOO SHORT")}.to raise_exception(ArgumentError)
        expect {RotorMachine::Factory.build_rotor(rotor_kind: "QWERTYUIOPASDFGHJKLZXCVBNMEXTRALETTERS")}.to raise_exception(ArgumentError)
      end
    end

    context "specifying initial position" do
      it "should allow specifying the initial position as a character" do
        expect {@r = RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: "A")}.not_to raise_exception
        expect(@r).to be_instance_of(RotorMachine::Rotor)
        expect(@r.current_letter).to be == "A"
      end

      it "should allow specifying the initial position as a number" do
        expect {@r = RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: 7)}.not_to raise_exception
        expect(@r).to be_instance_of(RotorMachine::Rotor)
        expect(@r.current_letter).to be == RotorMachine::Rotor::ROTOR_I[7]
        expect(@r.position).to be == 7
      end

      it "shoudl raise an error if the position letter is not present on the rotor" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: "*")}.to raise_error(ArgumentError)
      end

      it "should raise an error if the numeric position is out of range" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, 
                                                  initial_position: -1)}.to raise_error(ArgumentError)
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, 
                                                  initial_position: 38)}.to raise_error(ArgumentError)
      end
    end
  end
end
