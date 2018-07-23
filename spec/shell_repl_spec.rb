############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : shell_repl_spec.rb
# Specs for   : The REPL interface of the RotorMachine::Shell class.
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
require 'pty'

# Extensions to the String class to make testing a bit easier..
require_helper_named('string_extensions')

# Custom matcher to check rotor state
require_custom_matcher_named("rotor_state")
require_custom_matcher_named("reflector_state")

RSpec.describe "RotorMachine::Shell" do
  context "REPL Interface" do
  end
end
