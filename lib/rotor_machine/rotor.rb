module RotorMachine
  class Rotor

    attr_reader  :position
    attr_accessor :step_size

    ROTOR_IC = "DMTWSILRUYQNKFEJCAZBPGXOHV".freeze
    ROTOR_IIC = "HQZGPJTMOBLNCIFDYAWVEUSRKX".freeze
    ROTOR_IIIC = "UQNTLSZFMREHDPXKIBVYGJCWOA".freeze
    ROTOR_I = "JGDQOXUSCAMIFRVTPNEWKBLZYH".freeze
    ROTOR_II = "NTZPSFBOKMWRCJDIVLAEYUXHGQ".freeze
    ROTOR_III = "JVIUBHTCDYAKEQZPOSGXNRMWFL".freeze
    ROTOR_UKW = "QYHOGNECVPUZTFDJAXWMKISRBL".freeze
    ROTOR_ETW = "QWERTZUIOASDFGHJKPYXCVBNML".freeze
    ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze

    def initialize(rotor, start_on=0, step_size=1)
      @letters = rotor.chars.freeze
      self.position = start_on
      @step_size = step_size
      @wrapped = nil
    end

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

    def forward(letter)
      if ALPHABET.include?(letter)
        @letters[((ALPHABET.index(letter) + self.position) % @letters.length)]
      else
        letter
      end
    end

    def reverse(letter)
      if ALPHABET.include?(letter)
        ALPHABET[((@letters.index(letter) - self.position) % @letters.length)]
      else
        letter
      end
    end

    def step(step_size=@step_size)
      old_position = @position
      @position = (@position + step_size) % @letters.length
      @wrapped = (old_position > @position)
    end

    def current_letter
      @letters[@position]
    end

    def rotor_kind
      @letters.join("")
    end

    def rotor_kind_name
      self.class.constants.each { |k| return k if (self.class.const_get(k) == rotor_kind) }
      return :CUSTOM
    end

    def wrapped?
      @wrapped
    end

    def to_s
      return "a RotorMachine::Rotor of type '#{self.rotor_kind_name}', position=#{self.position} (#{self.current_letter}), step_size=#{@step_size}"
    end
  end
end
