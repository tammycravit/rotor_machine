# The Enigma Machine using Ruby ## Saturday, January 3, 2015

*From
https://ksylvest.com/posts/2015-01-03/the-enigma-machine-using-ruby*

An Enigma machine is a German engineered mechanical and electrical
cipher machine used commercially in the 1920s and more famously during
the Second World War. The machine's enciphering and deciphering played
the role of the antagonist in the recent film The Imitation Game
(loosely) following Alan Turings work at Bletchley Park. The machine
is spellbinding because of its 159 million million million combinations
it can cipher to (all before the invention of the transistor).

The machine is composed of three different 'scrambling' parts: rotors,
a plugboard, and a reflector. The machine's input comes from a keyboard,
travels through the electromechanical components and is finally displayed
on a lampboard as a highlighted letter.

## The Plugboard

The plugboard's role is to swap pairs of letters. An electronic signal
will pass through the plugboard twice (after leaving the keyboard and
before entering the lampboard). Any letter that isn't "plugged" will
output as itself.

## The Reflector

The reflector's role is to perform a substitution. It is a mapping of
every letter to a different letter (i.e. A to B and B to A, C to D and D
to C, etc). The relationship is defined in Mathematics to be reciprocal
(that is f(f(x)) = x).

## The Machine

These two components are enough to build a simple (ineffective) cipher
machine known as a substitution cipher. A letter flows into the plugboard
then to the reflector and finally back to the plugboard. To decrypt,
the encrypted message is sent through the same processes.

## The Rotor

Unfortunately a simple substitution cipher is easy to break because
letters always map to the same values. The cleverness behind the Enigma
machine is that it uses three (or sometimes four) rotors to perform
multiple layers of substitution. Rotors are bijective functions that have
one to one mappings for every letter. In the enigma machine the rotors
step like an odometer or a clock before each letter is processed. Only
when the first rotor performs a full rotation will the second rotor
turn. Similarly each subsequent rotor will turn after the previous rotor
cycles through all 26 positions. The processes of a rotor 'stepping'
changes the bijective mapping. Each rotor acts as a substitution cypher
and has a forward and reverse (inverse) mapping. The combination of
multiple rotors is known as a polyalphabetic substitution cipher.

## The Stepping

The example can have a few rotors added in. In addition to the existing
steps the machine now rotates the rotors and sends the letter forward and
reverse through the rotors before and after being reflected. The rotation
or stepping means that 26 cubed (17,576) different bijective functions
can be selected to map each letter in a string. The functions will change
on each rotation making it very difficult to find reoccurring patterns.

## Conclusion

The above example shows a simplified version of how an
Enigma machine works in Ruby. For a more complete example see:
https://github.com/ksylvest/enigma. The number of permutations the
Enigma machine allows for is so large because three of five rotors can
be selected in any order, two reflectors can be swapped, and any number
of letter mappings can be supplied with the plugboard. In addition the
initial settings for the machine allowed for the rotors and reflectors
to each start with 26 different offsets.
