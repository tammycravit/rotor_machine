module RotorMachine
  class Plugboard
    def initialize
      @connections = {}
    end

    def connect(from, to)
      if (connected?(from))
        raise ArgumentError, "#{from} is already connected"
      end
      if (connected?(to))
        raise ArgumentError, "#{to} is already connected"
      end
      if from == to
        raise ArgumentError, "#{from} cannot be connected to itself"
      end

      @connections[from] = to
      @connections[to] = from
    end

    def disconnect(letter)
      if (connected?(letter))
        other_end = @connections.delete(letter)
        @connections.delete(other_end)
      else
        raise ArgumentError, "#{letter} is not connected"
      end
    end

    def transpose(the_string)
      the_string.chars.collect { |c| @connections[c] || c }.join("")
    end

    def connected?(letter)
      @connections.keys.include?(letter)
    end
  end
end
