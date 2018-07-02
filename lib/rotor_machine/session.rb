module RotorMachine
  ##
  # The {Session} object provides a very simple DSL for "conversational" interactions
  # with the {RotorMachine::Machine} and its subordinate classes. This is useful for
  # interactive and experimental applications, for testing, and so forth.
  #
  # Eventually, a {Pry}-based REPL loop might be added to the project, but this
  # functionality does not exist yet.
  #
  # Instance methods are a loose wrapper around the rest of the library and are only
  # loosely documented here. Argument validation is handled by simply bubbling up
  # exceptions raised by the implementatation method.
  #
  # == Example Usage
  #
  #   RotorMachine.Session do
  #     default_machine
  #     
  #     set_rotors "AAA"
  #     connect "A", "G"
  #     encipher "THIS IS A SUPER SECRET MESSAGE"
  #     ct = last_result
  #     
  #     set_rotors "AAA"
  #     encipher ct
  #     puts last_result    # THISI SASUP ERSEC RETME SSAGE
  #   end
  class Session
    ##
    # Initialize the {RotorMachine::Session} instance. The methods of this object,
    # except for {#machine} and {#last_result}, are primarily intended to be
    # called within the {Session} block (via {instance_eval}).
    #
    # @param opts [Hash] The setup options hash. Currently unused, but any options
    #                    provided are stored.
    # @param block [Block] The operations block. If provided, it is executed via
    #                      {instance_eval}. The instance is returned following
    #                      execution of the block.
    def initialize(opts={}, &block)
      @opts = opts
      @machine = RotorMachine::Factory.empty_machine()
      @last_result = nil
      instance_eval(&block) if block_given?
      return self
    end

    ##
    # Create a rotor and add it to the machine.
    def rotor(kind, position=0, step_size=1)
      r = RotorMachine::Factory.build_rotor rotor_kind: kind,
        initial_position: position,
        step_size: step_size
      @machine.rotors << r if r.is_a?(RotorMachine::Rotor)
    end

    ##
    # Set the machine's reflector.
    def reflector(kind, position="A")
      r = RotorMachine::Factory.build_reflector reflector_kind: kind,
        initial_position: position
      @machine.reflector = r if r.is_a?(RotorMachine::Reflector)
    end

    ##
    # Connect a pair of letters on the machine's plugboard.
    def connect(from, to)
      @machine.plugboard.connect(from, to)
    end

    ##
    # Disconnect a letter (and its inverse) from the machine's plugboard.
    def disconnect(from)
      @machine.plugboard.disconnect(from)
    end

    ##
    # Encipher a string.
    def encipher(the_string="")
      res = @machine.encipher(the_string)
      @last_result = res
      res
    end

    ##
    #Set the positions of the rotors.
    def set_positions(pos_string)
      @machine.set_rotors(pos_string)
    end

    ##
    # Remove all rotors from the machine.
    def clear_rotors
      @machine.rotors = []
    end

    ##
    # Remove all connections from the plugboard.
    def clear_plugboard
      @machine.plugboard = RotorMachine::Plugboard.new
    end

    ##
    # Configure the machine to its default state (as in the {RotorMachine::Factory}
    # object's {default_machine} method.)
    def default_machine
      @machine = RotorMachine::Factory.default_machine
    end

    ##
    # Configure the machine to its empty state (as in the {RotorMachine::Factory}
    # object's {empty_machine} method.)
    def empty_machine
      @machine = RotorMachine::Factory.empty_machine
    end

    ##
    # Return the inner {RotorMachine::Machine} object.
    def machine
      @machine
    end

    ##
    # Return the results of the last {encipher} operation, or nil.
    def last_result
      @last_result
    end

    ##
    # {plug} is a convenience alias for {connect}
    alias_method "plug", "connect"

    ##
    # {unplug} is a convenience alias for {disconnect}
    alias_method "unplug", "disconnect"

    ##
    # {set_rotors} is a convenience alias for {set_positions}
    alias_method "set_rotors", "set_positions"

    ##
    # {encode} is a convenience alias for {encipher}
    alias_method "encode", "encipher"

    ##
    # {cipher} is a convenience alias for {encipher}
    alias_method "cipher", "encipher"

    ##
    # {the_machine} is a convenience alias for {machine}
    alias_method "the_machine", "machine"
  end

  ##
  # The class method Session is the entrypoint for the DSL. When invoked with a
  # block, it creates a new {RotorMachine::Session} object, passes the block to
  # it to be run with {instance_eval}, and then the {RotorMachine::Session} object
  # is returned to the caller.
  def self.Session(opts={}, &block)
    RotorMachine::Session.new(opts, &block)
  end
end
