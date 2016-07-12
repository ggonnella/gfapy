#
# Extensions of the String class to handle CIGAR strings
#
module RGFA::CIGAR

  # Parses a CIGAR string into an array of cigar operations,
  # each represented by a tuple of operation length and operation
  # symbol (one of MIDNSHPX=).
  #
  # @return ["*"] if self == "*"
  # @return [Array<RGFA::CigarOperation>] otherwise
  # @raise [TypeError] if the string is not a valid CIGAR string
  def cigar_operations
    return "*" if self == "*"
    raise TypeError if self !~ /^([0-9]+[MIDNSHPX=])+$/
    scan(/[0-9]+[MIDNSHPX=]/).map do |op|
      oplen = op[0..-2].to_i
      opcode = op[-1..-1]
      RGFA::CigarOperation.new([oplen, opcode])
    end
  end

  # Parses a CIGAR string representing an overlap and reverses it, i.e.
  # computes the CIGAR for the segments in reverse direction.
  # Returns an array of CIGAR operations.
  #
  # @see #reverse_cigar
  # @return ["*"] if self == "*"
  # @return [Array<RGFA::CigarOperation>] otherwise
  # @raise [TypeError] if the string is not a valid CIGAR string
  def reverse_cigar_operations
    return "*" if self == "*"
    self.cigar_operations.reverse.map do |oplen, opcode|
      if opcode == "I"
        opcode = "D"
      elsif opcode == "D"
        opcode = "I"
      end
      RGFA::CigarOperation.new([oplen, opcode])
    end
  end

  # Parses a CIGAR string representing an overlap and reverses it, i.e.
  # computes the CIGAR for the segments in reverse direction.
  #
  # @example
  #
  #   "2M1D3M".reverse_cigar # => "3M1I2M"
  #
  #   # S1 + S2 + 2M1D3M
  #   #
  #   # S1+  ACGACTGTGA
  #   # S2+      CT-TGACGG
  #   #
  #   # S2-  CCGTCA-AG
  #   # S1-     TCACAGTCGT
  #   #
  #   # S2 - S1 - 3M1I2M
  #
  #
  # @see #reverse_cigar_operations
  # @return ["*"] if self == "*"
  # @return [String] the reverse CIGAR, otherwise
  # @raise [TypeError] if the string is not a valid CIGAR string
  def reverse_cigar
    return "*" if self == "*"
    reverse_cigar_operations.flatten.join
  end

end

# Class representing a CIGAR operation
class RGFA::CigarOperation < Array
  # The operation length
  # @return [Integer] operation length
  def oplen
    self[0]
  end
  # The operation code
  # @return [String] <i>(length: 1)</i>
  #   operation code
  def opcode
    self[1]
  end
  # The string representation of the operation
  # @return [String]
  def to_s
    join
  end
end

class Array
  # @return [RGFA::CigarOperation]
  def to_cigar_operation
    kind_of?(RGFA::CigarOperation) ? self : RGFA::CigarOperation.new(self)
  end
end

class String
  include RGFA::CIGAR
end
