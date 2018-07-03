require 'readline'
require 'colorize'

module RotorMachine
  ##
  # Provide an interactive REPL for manipulating a {RotorMachine::Session} to create
  # and interact with a rotor machine.
  #
  # == Usage
  #
  #    shell = RotorMachine::Shell.new()
  #    shell.repl()
  class Shell

    ##
    # Shell command map. Each command in this list corresponds to a method in the
    # {RotorMachine::Shell class}. The key is the name of the command, and the
    # value is an array listing [description, arguments, aliases].
    COMMANDS =
    {
      rotor: ["Add a rotor to the machine", "<kind> [position] [step size]", "add_rotor"],
      reflector: ["Set the machine's reflector", "<kind> [position]", nil],
      connect: ["Connect two letters on the plugboard", "<from> <to>", "plug"],
      disconnect: ["Disconnnect a letter (and its inverse) on the plugboard", "<letter>", "unplug"],
      default_machine: ["Set the machine to its default configuration", nil, nil],
      empty_machine: ["Set the machine to its empty configuration", nil, nil],
      last_result: ["Print the result of the last encipherment operation", nil, nil],
      configuration: ["Print out the machine's current state", nil, "current_state,config"],
      set_positions: ["Set the rotor positions", "<positions>", "set_rotors"],
      clear_rotors: ["Clear the current rotor set", nil, nil],
      clear_plugboard: ["Clear the current plugboard configuration", nil, nil],
      "help": ["Display help", "[command]", nil],
      "version": ["Display the version of the rotor_machine library", nil, nil],
    }

    ##
    # Shell "external command" map. This functions the same as the {COMMANDS} list,
    # except for commands that are internal to the REPL and are implemented within the
    # logic of the {#repl} method.
    EXTERNAL_COMMANDS =
    {
      about_prompt: ["Information about the shell prompt", nil, nil],
      encipher: ["Encode a message", "[message]", "cipher,encode"],
      quit: ["Quit the application", nil, "exit"],
    }

    ##
    # Initialize a new {RotorMachine::Shell} instance, and the interior
    # {RotorMachine::Session} object which the shell manages.
    def initialize()
      @session = RotorMachine::Session.new({})
      @session.default_machine
    end

    ########## shell command handlers ##########

    ##
    # Wrapper around {RotorMachine::Session#rotor}. Expects rotor kind, position
    # and step size in the arglist.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def rotor(arglist)
      kind = arglist[0]
      position = arglist[1] || 0
      step_size = arglist[2] || 1

      @session.rotor(kind, position, step_size)
      "Added rotor #{@session.the_machine.rotors.count} of kind #{kind}"
    end

    ##
    # Wrapper around {RotorMachine::Session#reflector}. Expects reflector kind and
    # position in the arglist.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def reflector(arglist)
      kind = arglist[0]
      position = arglist[1] || 0
      @session.reflector(kind, position)
      "Set reflector of kind #{kind}"
    end

    ##
    # Wrapper around {RotorMachine::Session#connect}. Expects from and to letters
    # in the arglist.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def connect(arglist)
      from = arglist[0]
      to = arglist[1]

      @session.connect(from.upcase, to.upcase)
      "Connected #{from.upcase} to #{to.upcase} on plugboard"
    end

    ##
    # Wrapper around {RotorMachine::Session#disconnect}. Expects the letter to
    # disconnect in the arglist.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def disconnect(arglist)
      letter = arglist[0]
      @session.disconnect(letter.upcase)
      "Disconnected #{letter} and its inverse on plugboard"
    end

    ##
    # Wrapper around {RotorMachine::Session#encipher}. Expects the text to encipher
    # in the arglist.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def encipher(arglist)
      @session.encipher(arglist)
    end

    ##
    # Wrapper around {RotorMachine::Session#default_machine}. Arglist is ignored.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def default_machine(args)
      @session.default_machine
      "Reset machine to default configuration"
    end

    ##
    # Wrapper around {RotorMachine::Session#empty_machine}. Arglist is ignored.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def empty_machine(args)
      @session.empty_machine
      "Reset machine to empty configuration"
    end

    ##
    # Wrapper around {RotorMachine::Session#last_result}. Arglist is ignored.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def last_result(args)
      @session.last_result
    end

    ##
    # Print out the current configuration of the machine. Arglist is ignored.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def configuration(args)
      @session.the_machine.to_s
    end
    alias_method :current_state, :configuration
    alias_method :config, :configuration

    ##
    # Wrapper around {RotorMachine::Session#set_positions}. Expects a string
    # specifying the rotor positions in arglist[0].
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def set_positions(arglist)
      pos_string = arglist[0]
      @session.set_positions(pos_string)
      "Set rotors; rotor state is now #{rotor_state}"
    end
    alias_method :set_rotors, :set_positions

    ##
    # Wrapper around {RotorMachine::Session#clear_rotors}. Arglist is ignored.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def clear_rotors(args)
      @session.clear_rotors
      "Removed all rotors from the machine"
    end

    ##
    # Wrapper around {RotorMachine::Session#clear_plugboard}. Arglist is ignored.
    # @param arglist [Array] Array of arguments provided from the REPL
    # @return [String] A confirmation message, or an error message on failure.
    def clear_plugboard(args)
      @session.clear_plugboard
      "Removed all connections from the plugboard"
    end

    ##
    # Print command help. If an argument is specified in the first position of the
    # arglist, help about that specific command is printed. If no argument is
    # supplied, a list of commands is printed instead.
    def help(args)
      if args[0].nil? || args[0].empty?
        <<~HEREDOC

        #{verbs.keys.sort.collect { |k| "#{k}#{' ' *(20-k.length)} #{verbs[k][0]}" }.join("\n")}
        HEREDOC
      else
        cmd_info = verbs[args[0].to_sym]

        <<~HEREDOC

        #{args[0]}: #{cmd_info[0]}

        Usage  : #{args[0]} #{cmd_info[1]}
        Aliases: #{cmd_info[2] || "none"}

        HEREDOC
      end
    end

    ##
    # Print the version number of the rotor_machine.
    def version
      "rotor_machine version #{RotorMachine::VERSION}"
    end

    ########## Internal Helper Methods ##########

    ##
    # Return the selected letters on each of the rotors in the machine.
    def rotor_state
      @session.the_machine.rotors.collect { |r| r.letters[r.position]  }.join("")
    end

    ##
    # Check if `cmd` is included on the list of internal command verbs or is an
    # alias for an internal verb.
    def is_internal_verb?(cmd)
      aliases = []

      COMMANDS.each do |k, v|
        unless  v[2].nil?
          v[2].split(',').each { |a| aliases << a.to_sym  }
        end
      end

      COMMANDS.keys.include?(cmd) || aliases.include?(cmd)
    end

    ##
    # Return the combined list of command verbs and their arguments/usage.
    def verbs
      COMMANDS.merge(EXTERNAL_COMMANDS)
    end

    ##
    # Build the Readline prompt for the rotor machine. By default, displays the
    # following pieces of information:
    #
    #    - Count of rotors mounted to the machine
    #    - Count of connections on the plugboard
    #    - Current selected letters on the rotors
    #
    # If you redefine this method, you should also redefine the {#about_prompt}
    # method to describe the new prompt correctly.
    def readline_prompt
      [
        "[#{@session.the_machine.rotors.count}]".colorize(color: :light_blue),
        "<#{@session.the_machine.plugboard.connections.count}>".colorize(color: :light_blue),
        "#{rotor_state}".colorize(color: :light_blue),
        "> ".colorize(color: :white),
      ].join(" ")
    end

    ##
    # Display the about help for the REPL prompt. If you redefine the {#readline_prompt}
    # method, you should also redefine this to reflect the new prompt.
    def about_prompt
      puts ""
      puts "The prompt for the shell is in the following format:"
      puts ""
      puts "     [XXX] <YYY> ZZZ>"
      puts ""
      puts "The components of the prompt are as follows:"
      puts ""
      puts "     XXX - the number of rotors mounted to the machine"
      puts "     YYY - the number of connections on the plugboard"
      puts "     ZZZ - the current positions of the rotors"
      puts ""
    end

    ##
    # Display the startup banner for the REPL application.
    def banner
      puts "******************************************************************************".colorize(color: :white, background: :magenta)
      puts "*     rotor_machine: Simple simulation of the German WWII Enigma Machine     *".colorize(color: :white, background: :magenta)
      puts "*                   By Tammy Cravit <tammycravit@me.com>                     *".colorize(color: :white, background: :magenta)
      puts "*                http://github.com/tammycravit/rotor_machine                 *".colorize(color: :white, background: :magenta)
      puts "******************************************************************************".colorize(color: :white, background: :magenta)
      puts ""
      puts "rotor_machine version #{RotorMachine::VERSION}. Type 'help' for help. <Tab> to complete commands.".colorize(color: :magenta)
      puts ""
    end

    ########## REPL MAIN FUNCTION ##########

    ##
    # Provide an interactive REPL for manipulating the Rotor Machine. Essentially
    # this REPL is an interactive wrapper around the {RotorMachine::Session} object,
    # with tab completion and command history provided by the {Readline} library.
    def repl
      Readline.completion_append_character = " "
      Readline.completion_proc = proc { |s| verbs.keys.grep(/^#{Regexp.escape(s)}/)  }

      banner

      while input = Readline.readline(readline_prompt, true)
        begin
          unless input.empty?
            toks = input.tokenize
            cmd = toks.shift.downcase.strip

            if ['cipher', 'encipher', 'encode'].include?(cmd)
              message = toks.join(' ')
              puts self.encipher(message).colorize(color: :white).bold
            elsif ['exit', 'quit'].include?(cmd)
              break
            elsif 'about_prompt' == cmd
              about_prompt
            elsif self.is_internal_verb?(cmd.to_sym)
              begin
                if cmd == "last_result"
                  puts self.send(cmd.to_sym, toks).colorize(color: :white).bold
                else
                  puts self.send(cmd.to_sym, toks).colorize(color: :green)
                end
              rescue Exception => ex
                puts "Error: #{ex}".colorize(color: :red)
              end
            else
              puts "Unknown command: #{cmd}".colorize(color: :light_red).bold
            end
          end
        rescue StandardError => e
          puts "Rescued exception: #{e}".colorize(color: :red)
        end
      end
    end
  end
end
