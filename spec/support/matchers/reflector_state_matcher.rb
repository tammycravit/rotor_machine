############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : reflector_state_matcher.rb
# Description : RSpec custom matcher to make validating Reflector objects easier.
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
# The Reflector state matcher can be used to validate the state of a {Reflector}
# object. It accepts an options hash specifying the attributes to validate,
# which can include any or all of the following:
#
# - `kind`: This can either be a symbol representing one of the reflector
#   type constants (or :CUSTOM) or a string representing the sequence of
#   letters on the reflector. Because you might want to check the sequence
#   of letters on a standard reflector, passing in a string does *not* assume
#   a reflector type of :CUSTOM; you'll need to make a separate check for this
#   if desired.
#
# - `position`: Checks that the numeric position of the reflector matches the
#   provided value.
#
# - `letter`: Checks that the currently selected letter on the Reflector 
#   matches the provided value.
#
# In addition whichever options are specified, the matcher also validates that
# the provided object is non-nil and is an instance of a 
# {RotorMachine::Reflector}
RSpec::Matchers.define :have_reflector_state do |options|
  match do |the_reflector|
    @errors = []
    desired_kind      = options.fetch(:kind,      nil)
    desired_position  = options.fetch(:position,  nil)
    desired_letter    = options.fetch(:letter,    nil)

    if the_reflector.nil?
      @errors.push "expected the_reflector not to be nil"
      break
    end

    unless the_reflector.class.name == "RotorMachine::Reflector"
      @errors.push "expected the_reflector to be a RotorMachine::Reflector, got #{the_reflector.class.name}"
      break
    end

    unless desired_kind.nil?
      if desired_kind.class.name == "Symbol"
        unless the_reflector.reflector_kind_name == desired_kind
          @errors.push "expected reflector kind #{desired_kind}; got #{the_reflector.reflector_kind_name}"
        end
      elsif desired_kind.class.name == "String"
        unless the_reflector.letters == desired_kind
          @errors.push "expected reflector letters #{desired_kind}; got #{the_reflector.letters}"
        end
      else
        @errors.push "expected desired reflector kind to be a Symbol or String; got #{desired_kind.class.name}"
      end
    end

    unless desired_position.nil?
      unless the_reflector.position == desired_position
        @errors.push "expected reflector position to be #{desired_position}; got #{the_reflector.position}"
      end
    end

    unless desired_letter.nil?
      unless the_reflector.current_letter == desired_letter
        @errors.push "expected current letter to be #{desired_letter}; got #{the_reflector.current_letter}"
      end
    end

    @errors.empty?
  end

  failure_message do |actual|
    @errors.join("\n")
  end
end
