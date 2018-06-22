############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor machine.
#
# File        : machine_config_matcher_spec.rb
# Specs for   : The machine configuration custom matcher
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

require_custom_matcher_named('machine_config')

RSpec.describe "machine_config_matcher" do
  before(:each) do
    yaml_path      = File.join( File.dirname(__FILE__), "resources", "test_machine.yml" )
    @valid_machine = YAML.load_file(yaml_path)
  end

  context "the basics" do
    it "should be valid if a valid machine hash is provided" do
      expect(@valid_machine).to be_a_valid_machine_state_hash
    end

    it "should be invalid if the provided object is not a hash" do
      @valid_machine = 442
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if the provided obiect does not contain a serialization_version" do
      @valid_machine.delete(:serialization_version)
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end
  end

  context "rotor configuration" do
    it "should be invalid if the hash does not contain rotor definitions" do
      @valid_machine.delete(:rotors)
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if the rotor configurations don't contain the required elements" do
      no_kind = @valid_machine.clone
      no_kind[:rotors][0].delete(:kind)
      no_position = @valid_machine.clone
      no_position[:rotors][0].delete(:position)
      no_step_size = @valid_machine.clone
      no_step_size[:rotors][0].delete(:step_size)
      expect(no_kind).not_to be_a_valid_machine_state_hash
      expect(no_position).not_to be_a_valid_machine_state_hash
      expect(no_step_size).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a rotor kind isn't a symbol" do
      @valid_machine[:rotors][0][:kind] = nil
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a rotor kind is :CUSTOM, but letters aren't present" do
      @valid_machine[:rotors][2].delete(:letters)
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a rotor position isn't a number" do
      @valid_machine[:rotors][0][:position] = nil
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a rotor step size isn't a number" do
      @valid_machine[:rotors][0][:step_size] = nil
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a rotor position is out of range" do
      @valid_machine[:rotors][0][:position] = -1
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
      @valid_machine[:rotors][0][:position] = 63
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a rotor step size is out of range" do
      @valid_machine[:rotors][0][:step_size] = -63
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
      @valid_machine[:rotors][0][:position] = 63
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a rotor letter string is too short" do
      @valid_machine[:rotors][2][:letters] = "ABC"
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a rotor letter string is too long" do
      @valid_machine[:rotors][2][:letters] = "QWERTYUIOPASDFGHJKLZXCVBNMQQQQQJJ"
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end
  end

  context "reflector configuration" do
    it "should be invalid if the hash does not contain reflector definitions" do
      @valid_machine.delete(:reflector)
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if the reflector configuration doesn't contain the required elements" do
      no_kind = @valid_machine.clone
      no_kind[:reflector].delete(:kind)
      no_position = @valid_machine.clone
      no_position[:reflector].delete(:position)
      expect(no_kind).not_to be_a_valid_machine_state_hash
      expect(no_position).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a reflector kind isn't a symbol" do
      @valid_machine[:reflector][:kind] = nil
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a reflector position isn't a number" do
      @valid_machine[:reflector][:position] = nil
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a reflector position is out of range" do
      @valid_machine[:reflector][:position] = -1
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
      @valid_machine[:reflector][:position] = 63
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a reflector letter string is too short" do
      yaml_path      = File.join( File.dirname(__FILE__), "resources", "custom_reflector.yml" )
      valid_machine = YAML.load_file(yaml_path)
      valid_machine[:reflector][:letters] = "ABCDEF"
      expect(valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if a reflector letter string is too long" do
      yaml_path      = File.join( File.dirname(__FILE__), "resources", "custom_reflector.yml" )
      valid_machine = YAML.load_file(yaml_path)
      valid_machine[:reflector][:letters] = "QWERTYUIOPASDFGHJKLZXCVBNML"
      expect(valid_machine).not_to be_a_valid_machine_state_hash
    end
  end

  context "plugboard configuration" do
    it "should be invalid if the hash does not contain a plugboard definition" do
      @valid_machine.delete(:plugboard)
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end

    it "should be invalid if the plugboard hash does not contain connections" do
      @valid_machine[:plugboard].delete(:connections)
      expect(@valid_machine).not_to be_a_valid_machine_state_hash
    end
  end
end
