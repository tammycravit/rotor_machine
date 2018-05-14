############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor machine.
#
# File        : reflector_state_matcher_spec
# Specs for   : The reflector state custom matcher
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

RSpec.describe "reflector_state_matcher" do
  it "should detect a null reflector" do
    x = nil
    expect(x).not_to have_reflector_state({})
  end

  it "should detect an object that isn't a reflector" do
    x = {}
    expect(x).not_to have_reflector_state({})
  end

  it "should detect an invalid kind symbol" do
    x = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
    expect(x).not_to have_reflector_state({kind: :IHVALID})
  end

  it "should detect an incorrect kind string" do
    x = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
    expect(x).not_to have_reflector_state({kind: "QWERTYUIOPLKJHGFDSAZXCVBNM"})
  end

  it "should detect an invalid kind type" do
    x = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
    expect(x).not_to have_reflector_state({kind: {}})
  end

  it "should detect an incorrect position" do
    x = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
    expect(x).not_to have_reflector_state({kind: :REFLECTOR_A, position: 48})
  end

  it "should detect an incorrect current letter" do
    x = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
    expect(x).not_to have_reflector_state({kind: :REFLECTOR_A, letter: "?"})
  end
end
