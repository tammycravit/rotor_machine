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
end
