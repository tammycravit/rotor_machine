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

      it "should raise an error if the position letter is not present on the rotor" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: "*")}.to raise_error(ArgumentError)
      end

      it "should raise an error if the numeric position is out of range" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, 
                                                  initial_position: -1)}.to raise_error(ArgumentError)
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, 
                                                  initial_position: 38)}.to raise_error(ArgumentError)
      end
    end

    context "#build_plugboard" do
      it "should create a plugboard object" do
        pb = RotorMachine::Factory.build_plugboard()
          expect(pb).to be_instance_of(RotorMachine::Plugboard)
      end
    end

    context "#build_rotor_set" do
      it "should allow you to construct a set of rotors" do
        rs = RotorMachine::Factory.build_rotor_set([:ROTOR_I, :ROTOR_II, "QWERTYUIOPASDFGHJKLZXCVBNM"])
        expect(rs).to be_instance_of(Array)
        expect(rs.length).to be == 3

        expect(rs[0]).to be_instance_of(RotorMachine::Rotor)
        expect(rs[1]).to be_instance_of(RotorMachine::Rotor)
        expect(rs[2]).to be_instance_of(RotorMachine::Rotor)

        expect(rs[0].rotor_kind_name).to be == :ROTOR_I
        expect(rs[1].rotor_kind_name).to be == :ROTOR_II
        expect(rs[2].rotor_kind_name).to be == :CUSTOM
        expect(rs[2].rotor_kind).to be == "QWERTYUIOPASDFGHJKLZXCVBNM"
      end

      it "should allow you to specify initial positions" do
        rs = RotorMachine::Factory.build_rotor_set([:ROTOR_I, :ROTOR_II, :ROTOR_III], "CLP")
        expect(rs[0].current_letter).to be == "C"
        expect(rs[0].position).to be == RotorMachine::Rotor::ROTOR_I.index("C")
        expect(rs[1].current_letter).to be == "L"
        expect(rs[1].position).to be == RotorMachine::Rotor::ROTOR_II.index("L")
        expect(rs[2].current_letter).to be == "P"
        expect(rs[2].position).to be == RotorMachine::Rotor::ROTOR_III.index("P")
      end

      it "should not raise an error if the initial positions don't specify all rotors" do
        expect {RotorMachine::Factory.build_rotor_set([:ROTOR_I, :ROTOR_II, :ROTOR_III], "C")}.not_to raise_error
      end

      it "should not raise an error if the initial positions specify too many rotors" do
        expect {RotorMachine::Factory.build_rotor_set([:ROTOR_I, :ROTOR_II, :ROTOR_III], "CLFSNFNFHS")}.not_to raise_error
      end
    end

    context "#build_machine" do
      before(:each) do
        @rs = [
          RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: 0),
          RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_II, initial_position: 0),
          RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_III, initial_position: 0)
        ]
        @rf = RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A)
        @cn = {"A" => "Q", "R" => "Y"}
      end

      after(:each) do
        @rs = nil
        @rf = nil
        @cn = nil
      end

      it "should allow you to construct a machine with rotors and a reflector" do
        expect { @m = RotorMachine::Factory.build_machine(rotors: @rs, reflector: @rf) }.not_to raise_error

        expect(@m).to be_instance_of(RotorMachine::Machine)
        expect(@m.rotors.count).to be == 3
        expect(@m.rotors[0]).to be_instance_of(RotorMachine::Rotor)
        expect(@m.rotors[1]).to be_instance_of(RotorMachine::Rotor)
        expect(@m.rotors[2]).to be_instance_of(RotorMachine::Rotor)
        expect(@m.reflector).to be_instance_of(RotorMachine::Reflector)
        expect(@m.plugboard).to be_instance_of(RotorMachine::Plugboard)

        expect(@m.rotors[0].rotor_kind_name).to be == :ROTOR_I
        expect(@m.rotors[1].rotor_kind_name).to be == :ROTOR_II
        expect(@m.rotors[2].rotor_kind_name).to be == :ROTOR_III
        expect(@m.reflector.reflector_kind_name).to be == :REFLECTOR_A

        @m = nil
      end

      it "should allow you to construct a machine with an empty rotor set" do
        expect {@m = RotorMachine::Factory.build_machine(reflector: @rf)}.not_to raise_error
        expect(@m.rotors.count).to be == 0
        @m = nil
      end

      it "should allow you to construct a machine with no reflector loaded" do
        expect {@m = RotorMachine::Factory.build_machine(rotors: @rs)}.not_to raise_error
        expect(@m.reflector).to be_nil
        @m = nil
      end

      it "should allow you to construct a machine with plugboard connections specified" do
        expect {@m = RotorMachine::Factory.build_machine(rotors: @rs, reflector: @rf, connections: @cn)}.not_to raise_error
        "AQRY".chars.each { |l| expect(@m.plugboard.connected?(l)).to be_truthy }
        @m = nil
      end

      it "should allow you to specify rotors and reflectors as symbols" do
        expect {@m = RotorMachine::Factory.build_machine(
          rotors: [:ROTOR_I, :ROTOR_II, :ROTOR_III], 
          reflector: :REFLECTOR_A, 
          connections: @cn)}.not_to raise_error

        expect(@m).to be_instance_of(RotorMachine::Machine)
        expect(@m.rotors.count).to be == 3
        expect(@m.rotors[0]).to be_instance_of(RotorMachine::Rotor)
        expect(@m.rotors[1]).to be_instance_of(RotorMachine::Rotor)
        expect(@m.rotors[2]).to be_instance_of(RotorMachine::Rotor)
        expect(@m.reflector).to be_instance_of(RotorMachine::Reflector)
        expect(@m.plugboard).to be_instance_of(RotorMachine::Plugboard)

        expect(@m.rotors[0].rotor_kind_name).to be == :ROTOR_I
        expect(@m.rotors[0].position).to be == 0
        expect(@m.rotors[0].current_letter).to be == RotorMachine::Rotor::ROTOR_I[0]
        expect(@m.rotors[0].step_size).to be == 1

        expect(@m.rotors[1].rotor_kind_name).to be == :ROTOR_II
        expect(@m.rotors[1].position).to be == 0
        expect(@m.rotors[1].current_letter).to be == RotorMachine::Rotor::ROTOR_II[0]
        expect(@m.rotors[1].step_size).to be == 1
        
        expect(@m.rotors[2].rotor_kind_name).to be == :ROTOR_III
        expect(@m.rotors[2].position).to be == 0
        expect(@m.rotors[2].current_letter).to be == RotorMachine::Rotor::ROTOR_III[0]
        expect(@m.rotors[2].step_size).to be == 1

        expect(@m.reflector.reflector_kind_name).to be == :REFLECTOR_A
        @m = nil
      end

      it "should define make_* aliases for the build_* methods" do
        ["rotor", "reflector", "plugboard", "machine", "rotor_set"].each do |mn|
          expect(RotorMachine::Factory).to respond_to("make_#{mn}".to_sym)
          expect(RotorMachine::Factory.method("make_#{mn}".to_sym).original_name.to_s).to be == "build_#{mn}"
        end
      end

    end
  end
end
