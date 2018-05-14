module RotorMachine
  ##
  # Implementation of the Reflector rotor.
  #
  # A {Reflector} behaves similarly to a {RotorMachine::Rotor Rotor}, except
  # that the {Reflector} did not rotate. Its purpose is to reflect the
  # signal path back through the rotor stack in the opposite direction,
  # thereby ensuring that the encryption algorithm is symmetric.
  #
  # The module defines constants for the standard German Enigma reflectors,
  # but you can create a reflector with any string of 26 alphabetic
  # characters. However, you may not repeat a given letter more than once
  # in your string, or else the symmetry of the encipherment algorithm will
  # be broken.
  class Reflector

    ##
    # Allow querying the numeric position (ie, the initial position) of the
    # reflector.
    attr_reader :position

    ##
    # The letter mapping for the German "A" reflector.
    REFLECTOR_A      = "EJMZALYXVBWFCRQUONTSPIKHGD".freeze

    ##
    # The letter mapping for the German "B" reflector.
    REFLECTOR_B      = "YRUHQSLDPXNGOKMIEBFZCWVJAT".freeze

    ##
    # The letter mapping for the German "C" reflector.
    REFLECTOR_C      = "FVPJIAOYEDRZXWGCTKUQSBNMHL".freeze

    ##
    # The letter mapping for the German "B Thin" reflector.
    REFLECTOR_B_THIN = "ENKQAUYWJICOPBLMDXZVFTHRGS".freeze

    ##
    # The letter mapping for the German "C Thin" reflector.
    REFLECTOR_C_THIN = "RDOBJNTKVEHMLFCWZAXGYIPSUQ".freeze

    ##
    # The letter mapping for the German "ETW" reflector.
    REFLECTOR_ETW    = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze

    ##
    # A letter mapping for a passthrough reflector; also used by the RSpec tests
    ALPHABET        = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze

    ##
    # Initialize a new {Reflector}.
    #
    # @param selected_reflector [String] The character sequqnece for the
    #        reflector. You can use one of the class constants which define
    #        the standard German reflectors, or pass a custom sequence of
    #        26 letters.
    # @param start_position [Integer] The start position of the reflector.
    #        Because the reflector does not rotate, this is essentially just
    #        an additional permutation factor for the encipherment.
    def initialize(selected_reflector, start_position = 0)
      raise ArgumentError, "Initialization string contains duplicate letters" unless selected_reflector.is_uniq?

      @letters = selected_reflector.chars.freeze
      @alphabet = ALPHABET.chars.freeze
      @position = start_position
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
    # Feed a sequence of characters through the reflector, and return the
    # results.
    #
    # Any characters which are not present on the reflector will be passed
    # through unchanged.
    #
    # @param input [String] The string of characters to encipher.
    # @return [String] The results of passing the input string through the
    #         {Reflector}.
    def reflect(input)
      input.upcase.chars.each.collect { |c|
        if @alphabet.include?(c) then
          @letters[(@alphabet.index(c) + @position) % @alphabet.length]
        else
          c
        end }.join("")
    end

    ##
    # Return the reflector kind.
    #
    # If the {Reflector} is initialized with one of the provided rotor type
    # constants (such as {REFLECTOR_A}), the name of the reflector will be
    # returned as a symbol. If not, the symbol `:CUSTOM` will be returned..
    #
    # @return [Symbol] The kind of this {Reflector} object.
    def reflector_kind_name
      self.class.constants.each { |r| return r if (@letters.join("") == self.class.const_get(r)) }
      return :CUSTOM
    end

    ##
    # Return the sequence of letters on the reflector.
    # 
    # @return [String] The sequence of letters on the reflector.
    def letters
      @letters.join("")
    end

    ##
    # Get the current letter position of the rotor.
    #
    # @return [String] The current letter position of the rotor.
    def current_letter
      @letters[self.position]
    end

    ##
    # Return a human-readable representation of the {Reflector}
    #
    # @return [String] A description of the Reflector.
    def to_s
      "a RotorMachine::Reflector of type '#{self.reflector_kind_name.to_s}'"
    end

    ##
    # Compare this {RotorMachine::Reflector} to another one.
    #
    # Returns True if the configuration of the supplied {RotorMachine::Reflector}
    # matches this one, false otherwise.
    #
    # @param another_reflector [RotorMachine::Reflector] The Reflector to compare 
    # to this one.
    # @return [Boolean] True if the configurations match, false otherwise.
    def ==(another_reflector)
      self.letters == another_reflector.letters &&
      self.position == another_reflector.position
    end
  end
end
