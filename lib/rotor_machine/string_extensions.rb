##
# String extensions used by the {RotorMachine::Machine} to format output.
#
# @author Tammy Cravit <tammycravit@me.com>

class String

  ##
  # Detect if a string has any duplicated characters
  #
  # @return True if the string has no duplicated characters, false otherwise.
  def is_uniq?
    self.chars.uniq.length == self.chars.length
  end
  alias :uniq? :is_uniq?

  ##
  # Break a string into blocks of a certain number of characters.
  #
  # Encrypted text is often presented in blocks of 5 characters to disguise
  # word lengths in the ciphertext/plaintext. This method gives Ruby strings
  # the ability to break themselves into blocks of no more than a specified
  # number of characters.
  #
  # By default, the string is rejoined into a single string, with each
  # character group separated by a space. To return the string as an array
  # of chunks instead, pass a false value for the {rejoin} argument.
  #
  # @param block_size [Numeric] The maximum size of each block. Defaults
  #        to 5-character blocks if not provided.
  # @param rejoin [Boolean] True to join the blocks back into a single
  #        string, false to return an array of chunks instead. Defaults to
  #        true.
  # @return The string with each chunk separated by spaces, or an array of
  #         chunks if {rejoin} is false.
  def in_blocks_of(block_size=5, rejoin=true)
    if rejoin
      self.chars.reject{|s| s.match(/\s/)}.each_slice(block_size).map(&:join).join(" ") 
    else
      self.chars.reject{|s| s.match(/\s/)}.each_slice(block_size).map(&:join)
    end
  end
  alias :in_blocks :in_blocks_of

  ##
  # Break a string into words, including handling quoted substrings.
  #
  # @return An array of tokens, if the string can be tokenized.
  def tokenize
    self.
      split(/\s(?=(?:[^'"]|'[^']*'|"[^"]*")*$)/).
      select {|s| not s.empty? }.
      map {|s| s.gsub(/(^ +)|( +$)|(^["']+)|(["']+$)/,'')}
  end

  ##
  # Test if the string is a number.
  #
  # @return True if the string is a number, false otherwise.
  def is_number?
    true if Float(self) rescue false
  end


  ##
  # Strip ANSI color sequences from the string.
  #
  # @return The string with ANSI color sequences escaped.
  def uncolorize
    pattern = /\033\[([0-9]+);([0-9]+);([0-9]+)m(.+?)\033\[0m|([^\033]+)/m
    self.scan(pattern).inject("") do |str, match|
      str << (match[3] || match[4])
    end
  end
end
