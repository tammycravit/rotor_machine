module RotorMachine
  ##
  # The {RotorMachine::Factory} provides Factory-pattern helpers to build
  # various parts of the {RotorMachine} - rotors, reflectors, plugboards,
  # and fully-configured machines.
  module Factory
    extend self

    ##
    # Build a new {Rotor} and return it.
    #
    # The options hash for this method can accept the following named 
    # arguments:
    #
    # `:rotor_kind` - The type of rotor to create. Should be a symbol matching
    #                 a rotor type constant in the {RotorMachine::Rotor} class,
    #                 or a 26-character string giving the letter sequence for 
    #                 the rotor. Defaults to `:ROTOR_1` if not specified.
    #
    # `:initial_position` - The initial position of the rotor (0-based
    #                       numeric position, or a letter on the rotor.) Defaults
    #                       to 0 if not specified.
    #
    # `:step_size` - How many positions the rotor should advance with each
    #                step. Defaults to 1 if not specified.
    #
    # @param options [Hash] The options hash containing the options for the
    #                       rotor.
    # @return The newly-built rotor.
    def build_rotor(options={})
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

    ##
    # Build a new {Reflector} and return it.
    #
    # The options hash for this method can accept the following named 
    # arguments:
    #
    # `:reflector_kind` - The type of reflector to create. Should be a symbol matching
    #                 a reflector type constant in the {RotorMachine::Reflector} class,
    #                 or a 26-character string giving the letter sequence for 
    #                 the reflector. Defaults to `:REFLECTOR_A` if not specified.
    #
    # `:initial_position` - The initial position of the reflector (0-based
    #                       numeric position, or a letter on the rotor.) Defaults
    #                       to 0 if not specified.
    #
    # @param options [Hash] The options hash containing the options for the
    #                       reflector.
    # @return The newly-built reflector.
    def build_reflector(options={})
      reflector_kind     = options.fetch(:reflector_kind,   :REFLECTOR_A)
      initial_position   = options.fetch(:initial_position, 0)

      reflector_alphabet = nil

      if (reflector_kind.class.name == "Symbol")
        unless RotorMachine::Reflector.constants.include?(reflector_kind)
          raise ArgumentError, "Invalid reflector kind (symbol #{reflector_kind} not found)" 
        end
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

    ##
    # Build a new {Plugboard} object and return it.
    #
    # @return The newly built plugboard.
    def build_plugboard(options={})
      return RotorMachine::Plugboard.new()
    end

    ##
    # Build a set of {Rotor}s and return them.
    #
    # @param rotors [Array] A list of rotor types. Each type should be either
    # a symbol corresponding to a constant in the {Rotor} class, or a 26 
    # character string providing the sequence of letters for the rotor.
    # @param initial_positions [String] The starting letter to set each rotor
    # to.
    # @return [Array] An array of {Rotor} objects.
    def build_rotor_set(rotors=[], initial_positions=nil)
      ra = rotors.each.collect { |r| build_rotor(rotor_kind: r) }
      unless initial_positions.nil?
        ra.each_with_index do |r, i|
          unless initial_positions[i].nil?
            r.position = initial_positions[i] 
          end
        end
      end
      return ra
    end

    ##
    # Build a {Machine} and return it.
    #
    # The options hash can provide the following options:
    #
    # - `:rotors` - An array of {Rotor} objects. This can be constructed
    # manually, through multiple calls to {#build_rotor}, or through a single
    # call to {#build_rotor_set}.
    # - `:reflector` - A {Reflector object.
    # - `:connections` - A {Hash} of connections to make on the new {Machine}'s
    #   {Plugboard}.
    #
    # @param options The options for the newly built {Machine}.
    # @return The newly constructed {Machine}.
    def build_machine(options={})
      rotors    = options.fetch(:rotors,        [])
      reflector = options.fetch(:reflector,     nil)
      connections = options.fetch(:connections, {})

      m = RotorMachine::Machine.new()
      rotors.each { |r| m.rotors << r }
      m.reflector = reflector
      m.plugboard = RotorMachine::Plugboard.new()
      unless connections.empty?
        connections.each { |from, to| m.plugboard.connect(from, to) }
      end

      return m
    end

    ##
    # {make_rotor} is an alias for {build_rotor}
    alias :make_rotor :build_rotor

    ##
    # {make_reflector} is an alias for {build_reflector}
    alias :make_reflector :build_reflector

    ##
    # {make_plugboard} is an alias for {build_plugboard}
    alias :make_plugboard :build_plugboard

    ##
    # {make_machine} is an alias for {build_machine}
    alias :make_machine :build_machine

    ##
    # {make_rotor_set} is an alias for {build_rotor_set}
    alias :make_rotor_set :build_rotor_set
  end
end
