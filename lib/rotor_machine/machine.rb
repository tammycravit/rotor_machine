module RotorMachine
  ##
  # The {RotorMachine::Machine} class serves as the entrypoint and orchestrator
  # for an Enigma machine.
  #
  # == Components of an Enigma machine
  #
  # The Enigma machine, as represented by the RotorMachine module, consists
  # of the following components:
  #
  # - One or more rotors, which perform the transposition ciphering and also
  #   rotate to produce a polyalphabetic (rather than simple substitution)
  #   cipher.
  #
  # - A reflector, which performs a simple symmetric substitution of letters
  #
  # - A plugboard, which allows pairs of letters to be transposed on a
  #   per-message basis.
  #
  # On an actual Enigma machine, these components are all electromechanical,
  # and the Enigma also included a keyboard, a grid of lights to show the
  # results, and in some cases a printer. Since this is a simulated Enigma,
  # obviously, no keyboard/printer are supplied here.
  #
  # The polyalphabetic encryption of the Enigma comes from the fact that the
  # rotors are linked (mechanically in a real Enigma) so that they rotate
  # one or more "steps" after each character, changing the signal paths and
  # transpositions. This means that a sequence of the same plaintext character
  # will encipher to different ciphertext characters.
  #
  # The rotors are designed to advance such that each time a rotor completes
  # a full revolution, it will advance the rotor to its left once. The rotors
  # allow you to configure how many positions they advance when they do. So,
  # assuming all rotors are advancing one position at a time, if the rotors
  # have position "AAZ", their state after the next character is typed will
  # be "ABA".
  #
  # To learn much more about the inner workings of actual Enigma machines,
  # visit {https://en.wikipedia.org/wiki/Enigma_machine}.
  #
  # == The Signal Path of Letters
  #
  # On a physical Enigma machine, the electrical signal from a keypress is
  # routed through the plugboard, then through each of the rotors in sequence
  # from left to right. The signal then passes through the reflector (where it
  # is transposed again), then back through the rotors in reverse order, and
  # finally back through the plugboard a second time before being displayed on
  # the light grid and/or printer.
  #
  # One important consequence of this signal path is that encryption and
  # decryption are the same operation. That is to say, if you set the rotors
  # and plugboard, and then type your plaintext into the machine, you'll get
  # a string of ciphertext. If you then reset the machine to its initial state
  # and type the ciphertext characters into the machine, you'll produce your
  # original plaintext.
  #
  # One consequence of the Enigma's design is that a plaintext letter will
  # never encipher to itself. The Allies were able to exploit this property
  # to help break the Enigma's encryption in World War II.
  #
  # == Usage
  #
  # To use the RotorMachine Enigma machine, you need to perform the following
  # steps:
  #
  # 1. Create a new {RotorMachine::Machine} object.
  # 2. Add one or more {RotorMachine::Rotor Rotors} to the `rotors` array.
  # 3. Set the `reflector` to an instance of the {RotorMachine::Reflector Reflector} class.
  # 4. Make any desired connections in the {RotorMachine::Plugboard Plugboard}.
  # 5. Optionally, set the rotor positions with {#set_rotors}.
  #
  # You're now ready to encipher and decipher your text using the {#encipher}
  # method to encode/decode, and {#set_rotors} to reset the machine state.
  #
  # The {#default_machine} and {#empty_machine} class methods are shortcut
  # factory methods whcih set up, respectively, a fully configured machine
  # with a default set of rotors and reflector, and an empty machine with
  # no rotors or reflector.
  class Machine
    attr_accessor :rotors, :reflector, :plugboard

    ##
    # Generates a default-configuration RotorMachine, with the following
    # state:
    #
    # - Rotors I, II, III, each set to A and configured to advance a single
    #   step at a time
    # - Reflector A
    # - An empty plugboard with no connections
    def self.default_machine
      m = RotorMachine::Factory.build_machine(
        rotors: [:ROTOR_I, :ROTOR_II, :ROTOR_III],
        reflector: RotorMachine::Factory::build_reflector(reflector_kind: :REFLECTOR_A)
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
    def self.empty_machine
      RotorMachine::Factory.build_machine()
    end

    ##
    # Initialize a RotorMachine object.
    #
    # This object won't be usable until you add rotors, a reflector and a
    # plugboard. Using the {#default_machine} and {#empty_machine} helper class
    # methods is the preferred way to initialize functioning machines.
    def initialize()
      @rotors = []
      @reflector = nil
      @plugboard = nil
    end

    ##
    # Encipher (or decipher) a string.
    #
    # Each character of the string is, in turn, passed through the machine.
    # This process is documented in the class comment for the
    # {RotorMachine::Machine} class.
    #
    # Because the Enigma machine did not differentiate uppercase and lowercase
    # letters, the source string is upcase'd before processing.
    # @param text [String] the text to encipher or decipher
    # @return [String] the enciphered or deciphered text
    def encipher(text)
      raise ArgumentError, "Cannot encipher; no rotors loaded" if (@rotors.count == 0)
      raise ArgumentError, "Cannot encipher; no reflector loaded" if (@reflector.nil?)
      text.upcase.chars.collect { |c| self.encipher_char(c) }.join("").in_blocks_of(5)
    end

    ##
    # Coordinate the stepping of the set of rotors after a character is
    # enciphered.
    def step_rotors
      @rotors.reverse.each do |rotor|
        rotor.step
        break unless rotor.wrapped?
      end
    end

    ##
    # Set the initial positions of the set of rotors before begining an
    # enciphering or deciphering operation.
    #
    # This is a helper method to avoid having to manipulate the rotor
    # positions individually. Starting with the leftmost rotor, each
    # character from this string is used to set the position of one
    # rotor.
    #
    # If the string is longer than the number of rotors, the extra
    # values (to the right) are ignored. If it's shorter, the values of
    # the "extra" rotors will be unchanged.
    #
    # @param init_val [String] A string containing the initial values
    # for the rotors.
    def set_rotors(init_val)
      init_val.chars.each_with_index do |c, i|
        @rotors[i].position = c if (i < @rotors.length)
      end
    end

    ##
    # Describe the current state of the machine in human-readable form.
    #
    # @return [String] A description of the Rotor Machine's current internal
    # state.
    def to_s
      buf = "a RotorMachine::Machine with the following configuration:\n"
      buf += "  Rotors: #{@rotors.count}\n"
      @rotors.each { |r| buf += "    - #{r.to_s}\n" }
      buf += "  Reflector: #{@reflector.nil? ? "none" : @reflector.to_s}\n"
      buf += "  Plugboard: #{@plugboard.nil? ? "none" : @plugboard.to_s}"
      return buf
    end

    ##
    # Encipher a single character.
    #
    # Used by {#encipher} to walk a single character of text through the
    # signal path of all components of the machine.
    #
    # @param c [String] a single-character string containing the next
    #          character to encipher/decipher
    # @return [String] the enciphered/deciphered character. After the
    #         character passes through the machine, a call is made to
    #         {#step_rotors} to advance the rotors.
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

      unless ec == c
        self.step_rotors
      end
      ec
    end

    ##
    # Create a Ruby hash containing a snapshot of the current machine state.
    #
    # The hash returned by this method contains enough information to capture
    # the current internal state of the machine. Although you can invoke it
    # directly if you want to, it is primarily intended to be accessed via
    # the {#save_machine_state_to} and {#load_machine_state_from} methods,
    # which save and load machine state to YAML files.
    #
    # @return [Hash] A Hash representing the internal state of the machine.
    def machine_state
      machine_state = {}
      machine_state[:serialization_version] = RotorMachine::VERSION_DATA[0]

      machine_state[:rotors] = []
      self.rotors.each do |r|
        rstate = {
          kind: r.rotor_kind_name,
          position: r.position,
          step_size: r.step_size
        }
        if r.rotor_kind_name == :CUSTOM
          rstate[:letters] = r.rotor_kind
        end

        machine_state[:rotors] << rstate
      end
      machine_state[:reflector] = {
        kind: self.reflector.reflector_kind_name,
        position: self.reflector.position
      }
      if (self.reflector.reflector_kind_name == :CUSTOM)
        machine_state[:reflector][:letters] = self.reflector.letters
      end

      machine_state[:plugboard] = {
        connections: self.plugboard.connections.clone
      }
      return machine_state
    end

    ##
    # Write the internal machine state to a YAML file.
    #
    # The generated YAML file can be loaded using the #{load_machine_state_from}
    # method to restore a saved machine state.
    #
    # @param filepath [String] The path to the YAML file to which the machine
    # state should be saved.
    # @return [Boolean] True if the save operation completed successfully, false
    # if an error was raised.
    def save_machine_state_to(filepath)
      begin
        File.open(filepath, "w") do |f|
          f.puts machine_state.to_yaml
        end
        return true
      rescue
        return false
      end
    end

    ##
    # Read the internal machine state from a YAML file.
    #
    # The YAML file can be created using the #{save_machine_state_to} method to
    # save the machine state of an existing {RotorMachine::Machine} object.
    #
    # The internal state is captured as is, so if you save the state from a machine
    # that's not validly configured (no rotors, no reflector, etc.), the
    # reconstituted machine will also have an invalid state.
    #
    # @param filepath [String] The path to the YAML file to which the machine
    # state should be saved.
    # @return [Boolean] True if the save operation completed successfully, false
    # if an error was raised.
    def load_machine_state_from(filepath)
      raise ArgumentError, "File path \"#{filepath}\" not found!" unless File.exist?(filepath)
      begin
        config = YAML.load(filepath)
        if config[:serialization_version] > RotorMachine::VERSION_DATA[0]
          raise ArgumentError, "Serialization Data Version Mismatch"
        end
        self.set_machine_config_from(config)
        return true
      rescue
        return false
      end
    end

    ##
    # Create a new {RotorMachine::Machine} from a YAML configuration file.
    #
    # This class method is a one-step shortcut for creating an empty {RotorMachine::Machine}
    # and then loading its machine state.
    #
    # @param config [Hash] A configuration hash for the new machine, such as a config
    # hash generated by {#machine_state}.
    # @return [RotorMachine::Machine] A new {RotorMachine::Machine} created from the
    # supplied config hash.
    def self.from_yaml(config)
      m = self.empty_machine
      m.set_machine_config_from(config)
      return m
    end

    ##
    # Set the state of the machine based on values in a config hash.
    #
    # Any config hash (such as that generated by {#machine_state}) can be provided
    # as an argument, but this method is primarily intended to be accessed by the
    # {#from_yaml} and {#load_config_state_from} methods to deserialize a machine
    # state hash.
    #
    # @param config [Hash] The configuration hash describing the state of the
    # {RotorMachine::Machine}.
    # @return [RotorMachine::Machine] The {RotorMachine::Machine} which was just
    # configured.  def set_machine_config_from(config)
    def set_machine_config_from(config)
      @rotors = []
      @reflector = nil
      @plugboard = RotorMachine::Plugboard.new()

      # Create rotors
      config[:rotors].each do |rs|
        if rs[:kind] == :CUSTOM
          r = RotorMachine::Rotor.new(rs[:letters], rs[:position], rs[:step_size])
        else
          letters = RotorMachine::Rotor.const_get(rs[:kind])
          r = RotorMachine::Rotor.new(letters, rs[:position], rs[:step_size])
        end
        @rotors << r
      end

      # Create reflector
      if config[:reflector][:kind] == :CUSTOM
        letters = config[:reflector][:letters]
      else
        letters = RotorMachine::Reflector.const_get(config[:reflector][:kind])
      end
      @reflector = RotorMachine::Reflector.new(letters, config[:reflector][:position])

      # Plugboard mappings
      config[:plugboard][:connections].keys.each do |l|
        unless @plugboard.connected?(l)
          @plugboard.connect(l, config[:plugboard][:connections][l])
        end
      end

      return self
    end

    def ==(another_machine)
      @rotors == another_machine.rotors &&
        @reflector == another_machine.reflector &&
        @plugboard == another_machine.plugboard
    end
  end
end
