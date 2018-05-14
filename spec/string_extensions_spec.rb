############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : string_extensions_spec.rb
# Specs for   : The string extension helper methodss.
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

RSpec.describe "RotorMachine::StringExtensions" do
  before(:each) do
    @text = "THIS IS A TEST OF IN BLOCKS OF"
  end

  context "#is_uniq?" do
    it "should be a method of the String class" do
      expect("ABCDEF").to respond_to(:is_uniq?)
    end

    it "should return true if the string only contains unique characters" do
      expect("ABCDEF".is_uniq?).to be_truthy
    end

    it "should return false if the string contains duplicated characters" do
      expect("ABCCDEF".is_uniq?).not_to be_truthy
      expect("ABCCCCDEEEEF".is_uniq?).not_to be_truthy
    end
  end

  context "#in_blocks_of" do
    it "should be a method of the String class" do
      expect(@text).to respond_to(:in_blocks_of)
    end

    it "should allow reformatting output to joined 5-letter blocks by default" do
      expect(@text.in_blocks_of).to be == "THISI SATES TOFIN BLOCK SOF"
    end

    it "should allow reformatting output to a specified block length" do
      expect(@text.in_blocks_of(6)).to be == "THISIS ATESTO FINBLO CKSOF"
      expect(@text.in_blocks_of(50)).to be == "THISISATESTOFINBLOCKSOF"
    end

    it "should allow reformatting output to be returned as an array of chunks" do
      results = @text.in_blocks_of(5, nil)
      expect(results).to be_an(Array)
      expect(results.length).to be == 5

      %w{THISI SATES TOFIN BLOCK SOF}.each_with_index do |c, i|
        expect(results[i]).to be == c
      end
    end
  end

  context "#in_blocks" do
    it "should be a method of the String class" do
      expect(@text).to respond_to(:in_blocks)
    end

    it "should be an alias for #in_blocks_of" do
      expect(@text.method(:in_blocks).original_name).to be == :in_blocks_of
    end

    it "should allow reformatting output to joined 5-letter blocks by default" do
      expect(@text.in_blocks).to be == "THISI SATES TOFIN BLOCK SOF"
    end
  end
end
