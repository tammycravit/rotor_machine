module RotorMachine
  ##
  # Implment an Enigma machine rotor.
  #
  # The {Rotor} is the central component of the Enigma machine's polyalphabetic
  # substitution cipher. Each rotor consisted of a ring with a series of 
  # internal connections and wiring which mapped input letters on the left side
  # of the rotor to (different) output letters on the right side. The signal
  # from the Enigma's keyboard would pass twice through the rotor/reflector
  # stack (and plugboard) in opposite directions before being displayed. This
  # ensured the algorithm was symmetrical; without this property, the Enigma
  # could not both encipher and decipher text.
  #
  # Adding to the complexity of the algorithm, the rotors rotated after 
  # enciphering each character. In a standard 3-rotor Enigma machine, the
  # rightmost rotor advanced position for each character. The middle rotor
  # advanced one position with each full revolution of the right rotor, and
  # the left rotor advanced one position with each full rotation of the middle
  # rotor. These rotations permuted the signal path, so a sequence of several
  # of the same input character would produce different output characters.
  #
  # The {Rotor} as implemented here allows the `step_size` (the number of
  # positions each rotor advances when it's stepped) to be varied.
  class Rotor

    ##
    # Query the current numeric position (0-based) of the rotor. The {#position=}
    # method provides a setter for this property to allow for setting the
    # {Rotor} based on either a numeric position or a letter position.
    attr_reader  :position

    attr_reader :letters

    ##
    # Get or set the `step_size` - the number of positions the rotor should
    # advance every time it's stepped.
    attr_accessor :step_size

    ##
    # Provides the configuration of the German IC Enigma {Rotor}.
    ROTOR_IC = "DMTWSILRUYQNKFEJCAZBPGXOHV".freeze

    ##
    # Provides the configuration of the German IIC Enigma {Rotor}.
    ROTOR_IIC = "HQZGPJTMOBLNCIFDYAWVEUSRKX".freeze
    
    ##
    # Provides the configuration of the German IIIC Enigma {Rotor}.
    ROTOR_IIIC = "UQNTLSZFMREHDPXKIBVYGJCWOA".freeze
    
    ##
    # Provides the configuration of the German I Enigma {Rotor}.
    ROTOR_I = "JGDQOXUSCAMIFRVTPNEWKBLZYH".freeze
    
    ##
    # Provides the configuration of the German II Enigma {Rotor}.
    ROTOR_II = "NTZPSFBOKMWRCJDIVLAEYUXHGQ".freeze
    
    ##
    # Provides the configuration of the German III Enigma {Rotor}.
    ROTOR_III = "JVIUBHTCDYAKEQZPOSGXNRMWFL".freeze
    
    ##
    # Provides the configuration of the German UKW Enigma {Rotor}.
    ROTOR_UKW = "QYHOGNECVPUZTFDJAXWMKISRBL".freeze
    
    ##
    # Provides the configuration of the German ETW Enigma {Rotor}.
    ROTOR_ETW = "QWERTZUIOASDFGHJKPYXCVBNML".freeze
    
    ##
    # Provides the alphabet in order. Used for mapping rotor indices, but
    # could also be used as a {Rotor} configuration.
    ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze

    ##
    # Initialize a new rotor.
    #
    # @param rotor [String] The letter sequence used for the new rotor. In
    #        normal use, this should be one of the class constants which
    #        define the standard German Enigma rotors, but any sequence of
    #        26 unique letters can be used.
    # @param start_on [Integer] The (0-based) starting position for the rotor. 
    #        Defaults to 0. To start on a specific letter, use {#position=} to 
    #        set the rotor after creating it.
    # @param step_size [Integer] The number of positions to step the rotor
    #        each time it is advanced. Defaults to 1.
    def initialize(rotor, start_on=0, step_size=1)
      @letters = rotor.chars.freeze
      self.position = start_on
      @step_size = step_size
      @wrapped = nil
    end

    ##
    # Set the position of the {Rotor}.
    #
    # If a numeric position is provided, an {ArgumentError} will be raised if
    # the position is outside the bounds of the rotor. If an alphabetic position
    # is provided, an {ArgumentError} will be raised if the supplied character
    # is not a character represented on the rotor.
    #
    # @param pos [Numeric, String] The position of the rotor.
    def position=(pos)
      if pos.class.to_s == "String"
        raise ArgumentError, "#{pos[0]} is not a character on the rotor" unless @letters.include?(pos[0])
        @position = @letters.index(pos[0])
      elsif pos.class.to_s == "Integer"
        raise ArgumentError, "Position #{pos} is invalid" if (pos < 0 or pos > @letters.length)
        @position = pos
      else
        raise ArgumentError, "Invalid argument to position= (#{pos.class.to_s})"
      end
    end

    ## 
    # Return the "forward" (left-to-right) transposition of the supplied letter.
    #
    # @param letter [String] The letter to encipher.
    # @return [String] The enciphered letter.
    def forward(letter)
      if ALPHABET.include?(letter)
        @letters[((ALPHABET.index(letter) + self.position) % @letters.length)]
      else
        letter
      end
    end

    
    ## 
    # Return the "reverse" (right-to-left) transposition of the supplied letter.
    #
    # @param letter [String] The letter to encipher.
    # @return [String] The enciphered letter.
    def reverse(letter)
      if ALPHABET.include?(letter)
        ALPHABET[((@letters.index(letter) - self.position) % @letters.length)]
      else
        letter
      end
    end

    ## 
    # Step the rotor.
    #
    # @param step_size [Integer] The number of positions to step the rotor.
    #        Defaults to the value of {#step_size} if not provided.
    def step(step_size=@step_size)
      old_position = @position
      @position = (@position + step_size) % @letters.length
      @wrapped = (old_position > @position)
    end

    ##
    # Get the current letter position of the rotor.
    #
    # @return [String] The current letter position of the rotor.
    def current_letter
      @letters[@position]
    end

    ##
    # Return the current rotor's "kind" (a string containing the mappings of
    # the rotor.
    #
    # @return [String] The sequence of letters on the {Rotor}.
    def rotor_kind
      @letters.join("")
    end

    ## 
    # Return the name of this kind of rotor.
    #
    # If the rotor's sequence matches one of the defined class constants for a
    # standsard Enigma rotor, the name of the constant will be returned as a
    # symbol. Otherwise, :CUSTOM is returned.
    #
    # @return [Symbol] The name of the kind of this rotor.
    def rotor_kind_name
      self.class.constants.each { |k| return k if (self.class.const_get(k) == rotor_kind) }
      return :CUSTOM
    end

    ##
    # Check if the last {#step} operation caused the rotor to wrap around in
    # position. This is used by the {RotorMachine::Machine Machine} to determine
    # whether to advance the adjacent rotor.
    #
    # @return [Booleam] True if the last {#step} operation caused the rotor to 
    #         wrap around.
    def wrapped?
      @wrapped
    end

    ##
    # Generate a human-readable representation of the {Rotor}'s state.
    #
    # @return [String] The current state of the Rotor
    def to_s
      return "a RotorMachine::Rotor of type '#{self.rotor_kind_name}', position=#{self.position} (#{self.current_letter}), step_size=#{@step_size}"
    end

    ##
    # Compare this {RotorMachine::Rotor} to another one.
    #
    # Returns True if the configuration of the supplied {RotorMachine::Rotor} matches
    # this one, false otherwise.
    #
    # @param another_rotor [RotorMachine::Rotor] The Rotor to compare to this one.
    # @return [Boolean] True if the configurations match, false otherwise.
    def ==(another_rotor)
      @letters == another_rotor.letters &&
      position == another_rotor.position &&
      step_size == another_rotor.step_size
    end

  end
end
