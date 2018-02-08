module RotorMachine
  class Machine
    attr_accessor :rotors, :reflector, :plugboard

    def initialize()
      @rotors = []
      @reflector = nil
      @plugboard = nil
    end

    def encipher(text)
      text.chars.collect { |c| self.encipher_char(c) }.join("")
    end

    def encipher_char(c)
      ec = c
      ec = @plugboard.transpose(ec)
      @rotors.each { |rotor| ec = rotor.forward(ec) }
      ec = @reflector.reflect(ec)
      @rotors.reverse.each { |rotor| ec = rotor.reverse(ec) }
      ec = @plugboard.transpose(ec)
      self.step_rotors
      ec
    end

    def step_rotors
      @rotors.reverse.each do |rotor|
        rotor.step
        break unless rotor.wrapped?
      end
    end

    def set_rotors(init_val)
      init_val.chars.each_with_index do |c, i|
        @rotors[i].position = c if (i < @rotors.length)
      end
    end
  end
end
