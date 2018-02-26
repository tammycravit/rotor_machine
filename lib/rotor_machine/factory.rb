module RotorMachine
  ##
  # The {RotorMachine::Factory} provides Factory-pattern helpers to build
  # various parts of the {RotorMachine} - rotors, reflectors, plugboards,
  # and fully-configured machines.
  module Factory
    extend self

    ##
    # Generates a default-configuration RotorMachine, with the following
    # state:
    #
    # - Rotors I, II, III, each set to A and configured to advance a single
    #   step at a time
    # - Reflector A
    # - An empty plugboard with no connections
    #
    # The {RotorMachine::Machine#default_machine} method calls this factory
    # method, and is maintained there for backward compatibility.
    def default_machine
      m = build_machine(
        rotors: [:ROTOR_I, :ROTOR_II, :ROTOR_III],
        reflector: build_reflector(reflector_kind: :REFLECTOR_A)
        )
      m.set_rotors("AAA")
      return m
    end

    ##
    # Generates an empty-configuration RotorMachine, with the following
    # state:
    #
    # - No rotors
    # - No reflector
    # - An empty plugboard with no connections
    #
    # A RotorMachine in this state will raise an {ArgumentError} until you
    # outfit it with at least one rotor and a reflector.
    #
    # The {RotorMachine::Machine#default_machine} method calls this factory
    # method, and is maintained there for backward compatibility.
    def empty_machine
      return build_machine()
    end

    ##
    # Build a new {Rotor} and return it.
    #
    # The options hash for this method can accept the following named
    # arguments:
    #
    # *:rotor_kind* - The type of rotor to create. Should be a symbol matching
    # a rotor type constant in the {RotorMachine::Rotor} class,
    # or a 26-character string giving the letter sequence for
    # the rotor. Defaults to *:ROTOR_1* if not specified.
    #
    # *:initial_position* - The initial position of the rotor (0-based
    # numeric position, or a letter on the rotor.) Defaults
    # to 0 if not specified.
    #
    # *:step_size* - How many positions the rotor should advance with each
    # step. Defaults to 1 if not specified.
    #
    # @param options [Hash] The options hash containing the options for the
    #                       rotor.
    # @return The newly-built rotor.
    def build_rotor(options={})
      rotor_kind         = options.fetch(:rotor_kind, nil)
      initial_position   = options.fetch(:initial_position,   0)
      step_size          = options.fetch(:step_size,          1)

      rotor_alphabet = nil
      if rotor_kind.nil?
        raise ArgumentError, "Rotor kind not specified"
      end

      if rotor_kind.is_a? Symbol
        raise ArgumentError, "Invalid rotor kind (symbol #{rotor_kind} not found)" unless RotorMachine::Rotor.constants.include?(rotor_kind)
        rotor_alphabet = RotorMachine::Rotor.const_get(rotor_kind)
      elsif rotor_kind.is_a? String
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
    # *:reflector_kind* - The type of reflector to create. Should be a symbol matching
    # a reflector type constant in the {RotorMachine::Reflector} class,
    # or a 26-character string giving the letter sequence for
    # the reflector. Defaults to *:REFLECTOR_A* if not specified.
    #
    # *:initial_position* - The initial position of the reflector (0-based
    # numeric position, or a letter on the rotor.) Defaults
    # to 0 if not specified.
    #
    # @param options [Hash] The options hash containing the options for the
    # reflector.
    # @return The newly-built reflector.
    def build_reflector(options={})
      reflector_kind     = options.fetch(:reflector_kind, nil)
      initial_position   = options.fetch(:initial_position, nil)

      reflector_alphabet = nil
      if reflector_kind.nil?
        raise ArgumentError, "Reflector type not specified"
      end
      if initial_position.nil?
        initial_position = 0
      end

      if reflector_kind.is_a? Symbol
        unless RotorMachine::Reflector.constants.include?(reflector_kind)
          raise ArgumentError, "Invalid reflector kind (symbol #{reflector_kind} not found)"
        end
        reflector_alphabet = RotorMachine::Reflector.const_get(reflector_kind)
      elsif reflector_kind.is_a? String
        raise ArgumentError, "Invalid reflector kind (invalid length)" unless reflector_kind.length == 26
        reflector_alphabet = reflector_kind.upcase
      else
        raise ArgumentError, "Invalid reflector kind (invalid type)"
      end

      if initial_position.is_a? Numeric
        raise ArgumentError, "Invalid position (#{initial_position} out of range)" unless ((0..25).include?(initial_position))
      elsif initial_position.is_a? String
        unless RotorMachine::Reflector::ALPHABET.include?(initial_position)
          raise ArgumentError, "Invalid position (invalid letter '#{initial_position}')"
        end
        initial_position = reflector_alphabet.index(initial_position)
      else
        raise ArgumentError, "Invalid position (invalid type)"
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
    # Build a {Machine} and return it.
    #
    # The options hash can provide the following options:
    #
    # - *:rotors* - An array of {Rotor} objects. This can be constructed
    #   manually, or through multiple calls to {#build_rotor}.
    #   Alternatively, you can pass an array of
    #   symbols which match the constants in the {Rotor} class, and {Rotor}
    #   objects will be built from those (using default position and step
    #   sizes).
    #
    # - *:reflector* - A {Reflector} object. Alternatively, a symbol
    #   matching one of the reflector type constants can be passed in, and
    #   a {Reflector} of the specified type will be created.j
    #
    # - *:connections* - A {Hash} of connections to make on the new {Machine}'s
    #   {Plugboard}.
    #
    # @param options The options for the newly built {Machine}.
    # @return The newly constructed {Machine}.
    def build_machine(options={})
      rotors    = options.fetch(:rotors,        [])
      reflector = options.fetch(:reflector,     nil)
      connections = options.fetch(:connections, {})

      m = RotorMachine::Machine.new()
      rotors.each do |r|
        if r.is_a? RotorMachine::Rotor
          m.rotors << r
        elsif r.is_a? Symbol
          m.rotors << RotorMachine::Factory.build_rotor(rotor_kind: r)
        else
          raise ArgumentError, "#{r} is not a rotor or a rotor kind symbol"
        end
      end

      unless reflector.nil?
        if reflector.is_a? Symbol
          m.reflector = RotorMachine::Factory.build_reflector(reflector_kind: reflector)
        elsif reflector.is_a? RotorMachine::Reflector
          m.reflector = reflector
        else
          raise ArgumentError, "#{reflector} is not a reflector or reflector kind symbol"
        end
      end

      m.plugboard = build_plugboard()
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
  end
end
