require 'rspec/expectations'

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
