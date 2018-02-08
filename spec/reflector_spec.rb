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
end
