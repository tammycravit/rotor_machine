############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : rotor_state_matcher.rb
# Description : RSpec custom matcher to make validating Rotor objects easier.
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

##
# The Rotor state matcher can be used to validate the state of a {Rotor}
# object. It accepts an options hash specifying the attributes to validate,
# which can include any or all of the following:
#
# - `kind`: This can either be a symbol representing one of the rotor
#   type constants (or :CUSTOM) or a string representing the sequence of
#   letters on the rotor. Because you might want to check the sequence
#   of letters on a standard rotor, passing in a string does *not* assume
#   a rotor type of :CUSTOM; you'll need to make a separate check for this
#   if desired.
#   
# - `position`: Checks that the numeric position of the rotor matches the
#   provided value.
#
# - `letter`: Checks that the currently selected letter on the rotor 
#   matches the provided value.
#
# - `step_size`: Checks that the rotor's current step size matches the
#   provided value.
#
# In addition whichever options are specified, the matcher also validates that
# the provided object is non-nil and is an instance of a {RotorMachine::Rotor}
RSpec::Matchers.define :have_rotor_state do |options|
  match do |the_rotor|
    @errors = []
    desired_kind      = options.fetch(:kind,      nil)
    desired_position  = options.fetch(:position,  nil)
    desired_letter    = options.fetch(:letter,    nil)
    desired_step_size = options.fetch(:step_size, nil)

    if the_rotor.nil?
      @errors.push "expected the_rotor not to be nil"
      break
    end

    unless the_rotor.class.name == "RotorMachine::Rotor"
      @errors.push "expected the_rotor to be a RotorMachine::Rotor, got #{the_rotor.class.name}"
      break
    end

    unless desired_kind.nil?
      if desired_kind.class.name == "Symbol"
        unless the_rotor.rotor_kind_name == desired_kind
          @errors.push "expected rotor kind #{desired_kind}; got #{the_rotor.rotor_kind_name}"
        end
      elsif desired_kind.class.name == "String"
        unless the_rotor.rotor_kind == desired_kind
          @errors.push "expected rotor kind #{desired_kind}; got #{the_rotor.rotor_kind}"
        end
      else
        @errors.push "expected desired rotor kind to be a Symbol or String; got #{desired_kind.class.name}"
      end
    end

    unless desired_position.nil?
      unless the_rotor.position == desired_position
        @errors.push "expected rotor position to be #{desired_position}; got #{the_rotor.position}"
      end
    end

    unless desired_letter.nil?
      unless the_rotor.current_letter == desired_letter
        @errors.push "expected current letter to be #{desired_letter}; got #{the_rotor.current_letter}"
      end
    end

    unless desired_step_size.nil?
      unless the_rotor.step_size == desired_step_size
        @errors.push "expected step size to be #{desired_step_size}; got #{the_rotor.step_size}"
      end
    end
    @errors.empty?
  end

  failure_message do |actual|
    @errors.join("\n")
  end
end
