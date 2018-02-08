module RotorMachine
  ##
  # Plugboard implementaion for the {RotorMachine} Enigma simulation.
  #
  # The Plugboard was an enhancement to the original Enigma machine to add an
  # additional layer of transposition into the signal path. Signals passed
  # through the plugboard as they were leaving the keyboard and, to maintain
  # the symmetry of the Enigma's encryption, before being displayed on the
  # lightboard.
  #
  # The properties of the {Plugboard} which are relevant to how the encryption
  # works are:
  #
  # - Each letter may only be connected to one other letter.
  # - Connections are reciprocal. Connecting A to B also implies a connection
  #   from B to A.
  # - A letter cannot be connected to itself.
  class Plugboard

    ## 
    # Create a new, empty Plugboard object.
    #
    # By default, no letters are connected in the plugboard, and all input
    # characters are passed through unchanged.
    def initialize
      @connections = {}
    end

    ##
    # Connect a pair of letters on the {Plugboard}.
    #
    # The designations of "from" and "to" are rather arbitrary, since the
    # connection is reciprocal.
    #
    # An {ArgumentError} will be raised if either +from+ or +to+ are already
    # connected, or if you try to connect a letter to itself. 
    #
    # @param from [String] A single-character string designating the start
    #        of the connection.
    # @param to [String] A single-character string designating the end
    #        of the connection.
    def connect(from, to)
      from.upcase!
      to.upcase!
      raise ArgumentError, "#{from} is already connected" if (connected?(from))
      raise ArgumentError, "#{to} is already connected" if (connected?(to))
      raise ArgumentError, "#{from} cannot be connected to itself" if (to == from)

      @connections[from] = to
      @connections[to] = from
    end

    ##
    # Disconnect a plugboard mapping for a letter.
    #
    # Because the {Plugboard} mappings are reciprocal (they were represented by
    # a physical wire on the actual machine), this also removes the reciprocal
    # mapping.
    #
    # An {ArgumentError} is raised if the specified letter is not connected.
    #
    # @param letter [String] The letter to disconnect. You may specify the
    #        letter at either end of the mapping.
    def disconnect(letter)
      letter.upcase!
      if (connected?(letter))
        other_end = @connections.delete(letter)
        @connections.delete(other_end)
      else
        raise ArgumentError, "#{letter} is not connected"
      end
    end

    ##
    # Feed a string of characters through the {Plugboard} and return the mapped
    # characters. Characters which are not mapped are passed through unchanged
    # (but the parameter string is upcased before processing.
    #
    # @param the_string [String] The string being enciphered.
    # @return [String] The enciphered text.
    def transpose(the_string)
      the_string.upcase.chars.collect { |c| @connections[c] || c }.join("")
    end

    ##
    # Test if a particular letter is connected on the {Plugboard}.
    #
    # @param letter [String] The letter to test.
    # @return True if the letter is connected, nil otherwise.
    def connected?(letter)
      @connections.keys.upcase.include?(letter)
    end

    ## 
    # Produce a human-readable representation of the #{Plugboard}'s state.
    #
    # @return [String] A description of the current state.
    def to_s
      "a RotorMachine::Plugboard with connections: #{@connections.to_s}"
    end
  end
end
