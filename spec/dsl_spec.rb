
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

# Extensions to the String class to make testing a bit easier..
require_helper_named('string_extensions')

# Custom matcher to check rotor state
require_custom_matcher_named("rotor_state")
require_custom_matcher_named("reflector_state")

RSpec.describe "RotorMachine::Session" do
  context "basics" do
    it "should define a Session method" do
      expect(RotorMachine).to respond_to(:Session)
    end

    it "should yield the Session object after operations" do
      x = RotorMachine.Session do
      end
      expect(x).to be_a(RotorMachine::Session)
    end
  end

  context "#rotor" do
    it "should respond to the rotor operation" do
      expect(RotorMachine::Session.instance_methods).to include(:rotor)
    end

    it "should allow adding a rotor with a predefined type" do
      x = RotorMachine.Session do
        rotor :ROTOR_I
      end
      expect(x.the_machine.rotors.count).to be == 1
      expect(x.the_machine.rotors[0]).to be_a(RotorMachine::Rotor)
      expect(x.the_machine.rotors[0]).to have_rotor_state(
        rotor_kind: RotorMachine::Rotor::ROTOR_I,
        position: 0,
        step_size: 1
      )
    end

    it "should allow adding a rotor with a predefined type and position" do
      x = RotorMachine.Session do
        rotor :ROTOR_I, 13
      end
      expect(x.the_machine.rotors.count).to be == 1
      expect(x.the_machine.rotors[0]).to be_a(RotorMachine::Rotor)
      expect(x.the_machine.rotors[0]).to have_rotor_state(
        rotor_kind: RotorMachine::Rotor::ROTOR_I,
        position: 13,
        step_size: 1
      )
    end

    it "should allow adding a rotor with a predefined type, position, and step size" do
      x = RotorMachine.Session do
        rotor :ROTOR_I, 13, 2
      end
      expect(x.the_machine.rotors.count).to be == 1
      expect(x.the_machine.rotors[0]).to be_a(RotorMachine::Rotor)
      expect(x.the_machine.rotors[0]).to have_rotor_state(
        rotor_kind: RotorMachine::Rotor::ROTOR_I,
        position: 13,
        step_size: 2
      )
    end

    it "should add the rotors to the machine" do
      x = RotorMachine.Session do
        rotor :ROTOR_I, 13, 2
        rotor :ROTOR_II, 13, 2
      end
      expect(x.the_machine.rotors.count).to be == 2
    end
  end

  context "#reflector" do
    it "should allow specifying the reflector kind" do
      x = RotorMachine.Session do
        reflector :REFLECTOR_A
      end
      expect(x.the_machine.reflector).to be_a(RotorMachine::Reflector)
      expect(x.the_machine.reflector).to have_reflector_state(
        kind: RotorMachine::Reflector::REFLECTOR_A
      )
    end

    it "should allow specifying the reflector position" do
      x = RotorMachine.Session do
        reflector :REFLECTOR_A, 13
      end
      expect(x.the_machine.reflector).to be_a(RotorMachine::Reflector)
      expect(x.the_machine.reflector).to have_reflector_state(
        kind: RotorMachine::Reflector::REFLECTOR_A,
        position: 13
      )
    end
  end

  context "#connect" do
    it "should allow you to connect letters on the plugboard" do
      x = RotorMachine.Session do
        connect "A", "G"
      end
      expect(x.the_machine.plugboard.connected?("A")).to be_truthy
      expect(x.the_machine.plugboard.connected?("G")).to be_truthy
    end
  end

  context "#disconnect" do
    it "should allow you to disconnect letters from the plugboard" do
      x = RotorMachine.Session do
        connect "A", "G"
        disconnect "A"
      end
      expect(x.the_machine.plugboard.connected?("A")).not_to be_truthy
      expect(x.the_machine.plugboard.connected?("G")).not_to be_truthy
    end
  end

  context "#encipher" do
    it "should allow you to encipher a block of text" do
      x = RotorMachine.Session do
        default_machine
        encipher "THIS IS A TEST"
      end
      expect(x.last_result).to be == "QCTBG IJSWI H"
      expect(x.the_machine.rotors[0].letters[x.the_machine.rotors[0].position]).to be == "A"
      expect(x.the_machine.rotors[1].letters[x.the_machine.rotors[1].position]).to be == "A"
      expect(x.the_machine.rotors[2].letters[x.the_machine.rotors[2].position]).to be == "R"
    end
  end

  context "#set_positions" do
    it "should allow you reset the rotor positions" do
      x = RotorMachine.Session do
        default_machine
        ct = encipher "THIS IS A TEST"
        set_positions "AAA"
        encipher ct
      end
      expect(x.last_result).to be == "THISI SATES T"
      expect(x.the_machine.rotors[0].letters[x.the_machine.rotors[0].position]).to be == "A"
      expect(x.the_machine.rotors[1].letters[x.the_machine.rotors[1].position]).to be == "A"
      expect(x.the_machine.rotors[2].letters[x.the_machine.rotors[2].position]).to be == "R"
    end
  end

  context "#clear_rotors" do
    it "should allow you to remove all the rotors from the machine" do
      x = RotorMachine.Session do
        default_machine
        clear_rotors
      end
      expect(x.the_machine.rotors.count).to be == 0
    end
  end

  context "#clear_plugboard" do
    it "should allow you to remove all the plugboard connections" do
      x = RotorMachine.Session do
        default_machine
        connect "A", "G"
        connect "P", "Q"
        clear_plugboard
      end
      expect(x.the_machine.plugboard.connections.keys.count).to be == 0
    end
  end

  context "#default_machine" do
    it "should return the default machine" do
      x = RotorMachine.Session do
        default_machine
      end
      expect(x.the_machine).to be == RotorMachine::Factory.default_machine
    end
  end

  context "#empty_machine" do
    it "should return the empty machine" do
      x = RotorMachine.Session do
        empty_machine
      end
      expect(x.the_machine).to be == RotorMachine::Factory.empty_machine
    end
  end

  context "#the_machine" do
    it "should return the internal RotorMachine::Machine object" do
      x = RotorMachine.Session do
        default_machine
      end
      expect(x.the_machine).to be_a(RotorMachine::Machine)
    end
  end

  context "method aliases" do
    it "should define convenient aliases for method names" do
      expect(RotorMachine::Session.instance_method(:plug).original_name).to be == :connect
      expect(RotorMachine::Session.instance_method(:unplug).original_name).to be == :disconnect
      expect(RotorMachine::Session.instance_method(:set_rotors).original_name).to be == :set_positions
      expect(RotorMachine::Session.instance_method(:encode).original_name).to be == :encipher
      expect(RotorMachine::Session.instance_method(:cipher).original_name).to be == :encipher
      expect(RotorMachine::Session.instance_method(:the_machine).original_name).to be == :machine
    end
  end
end
