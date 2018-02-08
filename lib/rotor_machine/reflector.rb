module RotorMachine
  class Reflector

    REFLECTOR_A      = "EJMZALYXVBWFCRQUONTSPIKHGD".freeze
    REFLECTOR_B      = "YRUHQSLDPXNGOKMIEBFZCWVJAT".freeze
    REFLECTOR_C      = "FVPJIAOYEDRZXWGCTKUQSBNMHL".freeze
    REFLECTOR_B_THIN = "ENKQAUYWJICOPBLMDXZVFTHRGS".freeze
    REFLECTOR_C_THIN = "RDOBJNTKVEHMLFCWZAXGYIPSUQ".freeze
    REFLECTOR_ETW    = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze

    def initialize(selected_reflector, start_position = 0)
      @letters = selected_reflector.chars.freeze
      @alphabet = REFLECTOR_ETW.chars.freeze
      @position = start_position
    end

    def reflect(input)
      input.upcase.chars.each.collect { |c| 
        if @alphabet.include?(c) then 
          @letters[(@alphabet.index(c) + @position) % @alphabet.length] 
        else 
          c 
        end }.join("")
    end
  end
end
