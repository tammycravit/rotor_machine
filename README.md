# RotorMachine

The RotorMAchine gem provides a simple Ruby implementation of the [Enigma](https://en.wikipedia.org/wiki/Enigma_machine) rotor encryption machine.

I wrote RotorMachine primarily as an exercise in Test-Driven Development with RSpec. It is not intended to be efficient or performant, and I wasn't striving much for idiomatic conciseness. My aims were fairly modular code and a relatively complete RSpec test suite.

Many thanks to Kevin Sylvestre, whose [blog post](https://ksylvest.com/posts/2015-01-03/the-enigma-machine-using-ruby blog post) helped me understand some aspects of the internal workings of the Enigma and how the signals flowed through the pieces of the machine.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rotor_machine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rotor_machine

## Usage

The `RotorMachine::Machine` class serves as the entrypoint and orchestrator for an Enigma machine.
  
### Components of an Enigma machine
  
The Enigma machine, as represented by the RotorMachine module, consists
of the following components:
  
* One or more rotors, which perform the transposition ciphering and also
  rotate to produce a polyalphabetic (rather than simple substitution)
  cipher.
  
* A reflector, which performs a simple symmetric substitution of letters
  
* A plugboard, which allows pairs of letters to be transposed on a
  per-message basis.
  
On an actual Enigma machine, these components are all electromechanical,
and the Enigma also included a keyboard, a grid of lights to show the
results, and in some cases a printer. Since this is a simulated Enigma,
obviously, no keyboard/printer are supplied here.
  
The polyalphabetic encryption of the Enigma comes from the fact that the
rotors are linked (mechanically in a real Enigma) so that they rotate
one or more "steps" after each character, changing the signal paths and
transpositions. This means that a sequence of the same plaintext character
will encipher to different ciphertext characters.
  
The rotors are designed to advance such that each time a rotor completes
a full revolution, it will advance the rotor to its left once. The rotors
allow you to configure how many positions they advance when they do. So,
assuming all rotors are advancing one position at a time, if the rotors
have position "AAZ", their state after the next character is typed will
be "ABA".
  
To learn much more about the inner workings of actual Enigma machines,
visit [https://en.wikipedia.org/wiki/Enigma_machine].
  
###  The Signal Path of Letters
  
On a physical Enigma machine, the electrical signal from a keypress is
routed through the plugboard, then through each of the rotors in sequence
from left to right. The signal then passes through the reflector (where it
is transposed again), then back through the rotors in reverse order, and 
finally back through the plugboard a second time before being displayed on
the light grid and/or printer.
  
One important consequence of this signal path is that encryption and
decryption are the same operation. That is to say, if you set the rotors
and plugboard, and then type your plaintext into the machine, you'll get
a string of ciphertext. If you then reset the machine to its initial state
and type the ciphertext characters into the machine, you'll produce your
original plaintext.
  
One consequence of the Enigma's design is that a plaintext letter will
never encipher to itself. The Allies were able to exploit this property
to help break the Enigma's encryption in World War II.
  
### Usage

To use the RotorMachine Enigma machine, you need to perform the following
steps:
  
1. Create a new `RotorMachine::Machine` object.
2. Add one or more `RotorMachine::Rotor`s  to the `rotors` array.
3. Set the `reflector` to an instance of the `RotorMachine::Reflector` class.
4. Make any desired connections in the Plugboard.
5. Optionally, set the rotor positions with `#set_rotors`.
  
You're now ready to encipher and decipher your text using the `#encipher`
method to encode/decode, and `#set_rotors` to reset the machine state.
  
The `#default_machine` and `#empty_machine` class methods are shortcut
factory methods whcih set up, respectively, a fully configured machine 
with a default set of rotors and reflector, and an empty machine with
no rotors or reflector.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tammycravit/rotor_machine. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) license.

## Code of Conduct

Everyone interacting in the RotorMachine project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.comtammycravitrotor_machine/blob/master/CODE_OF_CONDUCT.md).
