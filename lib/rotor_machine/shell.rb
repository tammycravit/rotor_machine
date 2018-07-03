module RotorMachine
  class Shell
    # command: [description, args, aliases]
    COMMANDS =
    {
      rotor: ["Add a rotor to the machine", "<kind> [position] [step size]", nil],
      reflector: ["Set the machine's reflector", "<kind> [position]", nil],
      connect: ["Connect two letters on the plugboard", "<from> <to>", nil],
      disconnect: ["Disconnnect a letter (and its inverse) on the plugboard", "<letter>", nil],
      default_machine: ["Set the machine to its default configuration", nil, nil],
      empty_machine: ["Set the machine to its empty configuration", nil, nil],
      last_result: ["Print the result of the last encipherment operation", nil, nil],
      configuration: ["Print out the machine's current state", nil, "current_state, config"],
      set_positions: ["Set the rotor positions", "<positions>", "set_rotors"],
      clear_rotors: ["Clear the current rotor set", nil, nil],
      clear_plugboard: ["Clear the current plugboard configuration", nil, nil],
      "help": ["Display help", "[command]", nil]
    }
    EXTERNAL_COMMANDS =
    {
      about_prompt: ["Information about the shell prompt", nil, nil],
      encipher: ["Encode a message", "[message]", "cipher, encode"],
      quit: ["Quit the application", nil, "exit"],
    }

    def initialize()
      @session = RotorMachine::Session.new({})
      @session.default_machine
    end

    def rotor(arglist)
      kind = arglist[0]
      position = arglist[1] || 0
      step_size = arglist[2] || 1

      @session.rotor(kind, position, step_size)
      "Added rotor #{@session.the_machine.rotors.count} of kind #{kind}"
    end

    def reflector(arglist)
      kind = arglist[0]
      position = arglist[1] || 0
      @session.reflector(kind, position)
      "Set reflector of kind #{kind}"
    end

    def connect(arglist)
      from = arglist[0]
      to = arglist[1]

      @session.connect(from.upcase, to.upcase)
      "Connected #{from.upcase} to #{to.upcase} on plugboard"
    end

    def disconnect(arglist)
      letter = arglist[0]
      @session.disconnect(letter.upcase)
      "Disconnected #{letter} and its inverse on plugboard"
    end

    def encipher(arglist)
      @session.encipher(arglist)
    end

    def default_machine(args)
      @session.default_machine
      "Reset machine to default configuration"
    end

    def empty_machine(args)
      @session.empty_machine
      "Reset machine to empty configuration"
    end

    def last_result(args)
      @session.last_result
    end

    def configuration(args)
      @session.the_machine.to_s
    end
    alias_method :current_state, :configuration
    alias_method :config, :configuration

    def set_positions(arglist)
      pos_string = arglist[0]
      @session.set_positions(pos_string)
      "Set rotors; rotor state is now #{rotor_state}"
    end
    alias_method :set_rotors, :set_positions

    def clear_rotors(args)
      @session.clear_rotors
      "Removed all rotors from the machine"
    end

    def clear_plugboard(args)
      @session.clear_plugboard
      "Removed all connections from the plugboard"
    end

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

    def rotor_state
      @session.the_machine.rotors.collect { |r| r.letters[r.position]  }.join("")
    end

    def is_internal_verb?(cmd)
      COMMANDS.keys.include?(cmd.to_sym)
    end

    def verbs
      COMMANDS.merge(EXTERNAL_COMMANDS)
    end

    def readline_prompt
      "[#{@session.the_machine.rotors.count}] <#{@session.the_machine.plugboard.connections.count}> #{rotor_state}> "
    end

    def banner
      puts "******************************************************************************"
      puts "*     rotor_machine: Simple simulation of the German WWII Enigma Machine     *"
      puts "*                   By Tammy Cravit <tammycravit@me.com>                     *"
      puts "*                http://github.com/tammycravit/rotor_machine                 *"
      puts "******************************************************************************"
      puts ""
      puts "rotor_machine version #{RotorMachine::VERSION}. Type 'help' for help. <Tab> to complete commands."
      puts ""
    end

    def repl
      Readline.completion_append_character = " "
      Readline.completion_proc = proc { |s| verbs.keys.grep(/^#{Regexp.escape(s)}/)  }

      banner

      while input = Readline.readline(readline_prompt, true)
        begin
          toks = input.tokenize
          cmd = toks.shift.downcase.strip

          if ['cipher', 'encipher', 'encode'].include?(cmd)
            message = toks.join(' ')
            puts self.encipher(message)
          elsif ['exit', 'quit'].include?(cmd)
            break
          elsif 'about_prompt' == cmd
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
          else
            if self.is_internal_verb?(cmd.to_sym)
              begin
                puts self.send(cmd.to_sym, toks)
              rescue Exception => ex
                puts "Error: #{ex}"
              end
            else
              puts "Unknown command: #{cmd}"
            end
          end
        rescue StandardError => e
          puts "Rescued exception: #{e}"
        end
      end
    end
  end
end
