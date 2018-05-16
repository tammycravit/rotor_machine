############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : machine_state_matcher.rb
# Description : RSpec custom matcher to make validating Machine State hashes
#               easier.
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

require 'rspec/expectations'

RSpec::Matchers.define :be_a_valid_machine_state_hash do
  match do |actual|
    @errors = []

    # Validate that the serialized data contains rotors, reflector and
    # plugboard data.
    @errors.push("expected machine state to be a Hash") unless actual.is_a?(Hash)
    [:serialization_version, :rotors, :reflector, :plugboard].each do |elem|
      @errors.push("expected machine state to include #{elem}") unless actual.keys.include?(elem)
    end

    # Validate that all the reflector state is captured.
    refl = actual[:reflector]
    @errors.push("expected reflector state to be a Hash") unless refl.is_a?(Hash)
    [:kind, :position].each do |elem|
      unless refl.keys.include?(elem)
        @errors.push("expected reflector state to include #{elem}")
      end
    end
    @errors.push("expected reflector kind to be a Symbol") unless refl[:kind].is_a?(Symbol)
    @errors.push("expected reflector position to be an Integer") unless refl[:position].is_a?(Integer)
    @errors.push("reflector position #{refl[:position]} is out of range") unless (0..25).include?(refl[:position])
    if (refl[:kind] == :CUSTOM)
      @errors.push("expected custom reflector to define letters") unless refl.keys.include?(:letters)
      @errors.push("expected custom reflector letters to be a String") unless refl[:letters].is_a?(String)
      unless refl[:letters].length == 26
        @errors.push("custom reflector letters length #{refl[:letters].length} out is out of range")
      end
    end

    # Validate that the plugboard state is captured.
    pb = actual[:plugboard]
    @errors.push("expected plugboard kind to be a Hash") unless pb.is_a?(Hash)
    @errors.push("expected plugboard state to include connections") unless pb.keys.include?(:connections)
    @errors.push("expected plugboard connections to be a Hash") unless pb[:connections].is_a?(Hash)

    # Validate that the rotor state is captured.
    rotors = actual[:rotors]
    @errors.push("expected rotor state to be an Array") unless rotors.is_a?(Array)

    # Validate the state of each rotor.
    rotors.each_with_index do |r, i|
      @errors.push("Expected rotor #{i} state to be a Hash") unless r.is_a?(Hash)
      [:kind, :position, :step_size].each do |elem|
        @errors.push("Expected rotor #{i} to include #{elem}") unless r.keys.include?(elem)
      end
      @errors.push("Expected rotor #{i} kind to be a Symbol") unless r[:kind].is_a?(Symbol)
      [:position, :step_size].each do |elem|
        @errors.push("Expected rotor #{i} #{elem} to be an Integer") unless r[elem].is_a?(Integer)
        unless (0..25).include?(r[elem])
          @errors.push("Rotor #{i} #{elem} value #{r[elem]} is out of range")
        end
      end
      if r[:kind] == :CUSTOM
        @errors.push("Expected rotor #{i} to include :letters") unless r.keys.include?(:letters)
        @errors.push("expected rotor #{i} letters to be a String") unless r[:letters].is_a?(String)
        unless r[:letters].length == 26
          @errors.push("rotor #{i} letters length #{r[:letters].length} out is out of range")
        end
      end
    end

    # Did we get any errors?
    @errors.empty?
  end

  failure_message do
    @errors.join("\n")
  end
end
