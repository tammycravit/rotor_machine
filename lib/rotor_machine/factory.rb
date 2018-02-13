module RotorMachine
  class Factory
    def self.build_rotor(options={})
      rotor_kind         = options.fetch(:rotor_kind,         :ROTOR_I)
      initial_position   = options.fetch(:initial_position,   0)
      step_size          = options.fetch(:step_size,          1)

      rotor_alphabet = nil

      if (rotor_kind.class.name == "Symbol")
        raise ArgumentError, "Invalid rotor kind (symbol #{rotor_kind} not found)" unless RotorMachine::Rotor.constants.include?(rotor_kind)
        rotor_alphabet = RotorMachine::Rotor.const_get(rotor_kind)
      elsif (rotor_kind.class.name == "String")
        raise ArgumentError, "Invalid rotor kind (invalid length)" unless rotor_kind.length == 26
        rotor_alphabet = rotor_kind.upcase
      else
        raise ArgumentError, "Invalid rotor kind (invalid type #{rotor_kind.class.name})"
      end

      if initial_position.is_a? Numeric
        raise ArgumentError, "Invalid position (#{initial_position} out of range)" unless ((0..25).include?(initial_position))
      elsif initial_position.is_a? String
        unless RotorMachine::Rotor::ALPHABET.include?(initial_position)
          raise ArgumentError, "Invalid position (invalid letter '#{initial_position}')"
        end
      else
        raise ArgumentError, "Invalid position (invalid type #{initial_position.class.name})"
      end

      if  step_size.is_a? Numeric
        raise ArgumentError, "Invalid step size (#{step_size} out of range)" unless ((1..25).include?(step_size))
      else
        raise ArgumentError, "Invalid step size (invalid type #{step_size.class.name})"
      end

      return RotorMachine::Rotor.new(rotor_alphabet, initial_position, step_size)
    end

    def self.build_reflector(options={})
      reflector_kind     = options.fetch(:reflector_kind,     :reflector_I)
      initial_position   = options.fetch(:initial_position,   0)

      reflector_alphabet = nil

      if (reflector_kind.class.name == "Symbol")
        raise ArgumentError, "Invalid reflector kind (symbol #{reflector_kind} not found)" unless RotorMachine::Reflector.constants.include?(reflector_kind)
        reflector_alphabet = RotorMachine::Reflector.const_get(reflector_kind)
      elsif (reflector_kind.class.name == "String")
        raise ArgumentError, "Invalid reflector kind (invalid length)" unless reflector_kind.length == 26
        reflector_alphabet = reflector_kind.upcase
      else
        raise ArgumentError, "Invalid reflector kind (invalid type #{reflector_kind.class.name})"
      end

      if initial_position.is_a? Numeric
        raise ArgumentError, "Invalid position (#{initial_position} out of range)" unless ((0..25).include?(initial_position))
      elsif initial_position.is_a? String
        unless RotorMachine::Reflector::ALPHABET.include?(initial_position)
          raise ArgumentError, "Invalid position (invalid letter '#{initial_position}')"
        end
        initial_position = reflector_alphabet.index(initial_position)
      else
        raise ArgumentError, "Invalid position (invalid type #{initial_position.class.name})"
      end

      return RotorMachine::Reflector.new(reflector_alphabet, initial_position)
    end
  end
end
