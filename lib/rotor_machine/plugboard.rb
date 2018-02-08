module RotorMachine
  class Plugboard
    def initialize
      @connections = {}
    end

    def connect(from, to)
      raise ArgumentError, "#{from} is already connected" if (connected?(from))
      raise ArgumentError, "#{to} is already connected" if (connected?(to))
      raise ArgumentError, "#{from} cannot be connected to itself" if (to == from)

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

    def to_s
      "a RotorMachine::Plugboard with connections: #{@connections.to_s}"
    end
  end
end
