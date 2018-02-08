module RotorMachine
  class Machine
    attr_accessor :rotors, :reflector, :plugboard

    def self.default_machine
       machine = self.empty_machine
       machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_I, "A", 1)
       machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_II, "A", 1)
       machine.rotors << RotorMachine::Rotor.new(RotorMachine::Rotor::ROTOR_III, "A", 1)
       machine.reflector = RotorMachine::Reflector.new(RotorMachine::Reflector::REFLECTOR_A)
       machine
    end

    def self.empty_machine
       machine = RotorMachine::Machine.new()
       machine.rotors = []
       machine.reflector = nil
       machine.plugboard = RotorMachine::Plugboard.new()
       machine
    end

    def initialize()
      @rotors = []
      @reflector = nil
      @plugboard = nil
    end

    def encipher(text)
      raise ArgumentError, "Cannot encipher; no rotors loaded" if (@rotors.count == 0)
      raise ArgumentError, "Cannot encipher; no reflector loaded" if (@reflector.nil?)
      text.chars.collect { |c| self.encipher_char(c) }.join("")
    end

    def encipher_char(c)
      ec = c

      unless @plugboard.nil?
        ec = @plugboard.transpose(ec)
      end

      @rotors.each { |rotor| ec = rotor.forward(ec) }
      ec = @reflector.reflect(ec)
      @rotors.reverse.each { |rotor| ec = rotor.reverse(ec) }

      unless @plugboard.nil?
        ec = @plugboard.transpose(ec)
      end

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
