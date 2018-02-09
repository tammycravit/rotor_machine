##
# String extensions used by the {RotorMachine::Machine} to format output.
#
# @author Tammy Cravit <tammycravit@me.com>

class String
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
end
