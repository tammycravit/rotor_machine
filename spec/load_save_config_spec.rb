############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : load_save_config_spec.rb
# Specs for   : Loading and saving machine configurations.
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
require 'yaml'

# Extensions to the String class to make testing a bit easier..
require_helper_named('string_extensions')

# Load our custom matchers
require_custom_matcher_named("rotor_state")
require_custom_matcher_named("reflector_state")
require_custom_matcher_named("machine_config")

RSpec.describe "RotorMachine::Machine (serialization)" do
  context "serializing machine state" do
    before(:each) do
      @m = RotorMachine::Machine.default_machine()
      @m.rotors[2] = RotorMachine::Rotor.new("QWERTYUIOPLKJHGFDSAZXCVBNM", 0, 1)
      @m.reflector = RotorMachine::Reflector.new("QWERTYUIOPASDFGHJKLZXCVBNM", 0)
      @m.plugboard.connect('A', 'Q')
      @m.plugboard.connect('F', 'P')
    end

    after(:each) do
      @m = nil
      File.delete("/tmp/machine_config.yml") if File.exist?("/tmp/machine_config.yml")
    end

    it "should know how to generate a config hash of its internal state" do
      expect(@m).to respond_to(:machine_state)
      expect(@m.machine_state).to be_a(Hash)
    end

    it "should serialize all of the machine's state to the config hash" do
      expect(@m.machine_state).to be_a_valid_machine_state_hash
    end

    it "should know how to write config state to a file" do
      expect(@m).to respond_to(:save_machine_state_to)
      @m.save_machine_state_to("/tmp/machine_config.yml")
      expect(File).to exist("/tmp/machine_config.yml")
    end

    it "should raise an error if the requested file can't be written to" do
      expect(Dir).not_to exist("/tmp/nonexistent_dir")
      expect(@m.save_machine_state_to("/tmp/nonexistent_dir/machine_config.yml")).to be_falsy
    end
  end

  context "deserializing machine state" do
    before(:all) do
      @yaml_path = File.join( File.dirname(__FILE__), "resources", "test_machine.yml")
      @src_machine = RotorMachine::Machine.default_machine
      @src_machine.rotors[2] = RotorMachine::Factory::build_rotor(
        rotor_kind: "QWERTYUIOPLKJHGFDSAZXCVBNM",
        initial_position: 1,
        step_size: 1
      )
      @src_machine.plugboard.connect 'A', 'Q'
      @src_machine.plugboard.connect 'Y', 'F'
      @src_machine.save_machine_state_to(@yaml_path)
    end

    it "should be able to load the config state from a file" do
      m = RotorMachine::Machine.empty_machine
      expect { m.load_machine_state_from(@yaml_path) }.not_to raise_error
    end

    it "should be able to load the machine state from a config hash" do
      machine_state = YAML.load_file(@yaml_path)

      expect(RotorMachine::Machine).to respond_to(:from_yaml)
      m = RotorMachine::Machine.from_yaml(machine_state)
      expect(m).to be == @src_machine
    end

    it "should be able to read a machine with a custom reflector" do
      yaml_path = File.join( File.dirname(__FILE__), "resources", "custom_reflector.yml")
      machine_state = YAML.load_file(yaml_path)
      m = RotorMachine::Machine.from_yaml(machine_state)
      expect(m.reflector.reflector_kind_name).to be == :CUSTOM
      expect(m.reflector.letters).to be == "QWERTYUIOPLKJHGFDSAZXCVBNM"
    end

    it "should raise an error if a nonexistent file is specified" do
      bogus_file = File.join( File.dirname(__FILE__), "resources", "bogus.yml")
      expect(File).not_to exist(bogus_file)
      m = RotorMachine::Machine.empty_machine
      expect {m.load_machine_state_from(bogus_file)}.to raise_error(ArgumentError)
    end

    it "should raise an error if an incompatibly old YAML hash version is provided" do
      machine_state = YAML.load_file(@yaml_path)
      machine_state[:serialization_version] = -1
      expect {RotorMachine::Machine.from_yaml(machine_state)}.to raise_error(ArgumentError)
    end

    it "should raise an error if an incompatibly new YAML hash version is provided" do
      machine_state = YAML.load_file(@yaml_path)
      machine_state[:serialization_version] = RotorMachine::VERSION_DATA[0] + 1
      expect {RotorMachine::Machine.from_yaml(machine_state)}.to raise_error(ArgumentError)
    end

    it "should raise an error if no YAML hash version is provided" do
      machine_state = YAML.load_file(@yaml_path)
      machine_state.delete(:serialization_version)
      expect {RotorMachine::Machine.from_yaml(machine_state)}.to raise_error(ArgumentError)
    end
  end
end
