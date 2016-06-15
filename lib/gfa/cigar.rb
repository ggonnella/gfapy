#
# Extensions of the String class to handle CIGAR strings
#
module GFA::CIGAR

  # Parses a CIGAR string into an array of cigar operations,
  # each represented by a tuple of operation length and operation
  # symbol (one of MIDNSHPX=).
  #
  # @return ["*"] if self == "*"
  # @return [Array<Integer, String(1)>] otherwise
  def cigar_operations
    return "*" if self == "*"
    raise TypeError if self !~ /^([0-9]+[MIDNSHPX=])+$/
    scan(/[0-9]+[MIDNSHPX=]/).map do |op|
      oplen = op[0..-2].to_i
      opcode = op[-1..-1]
      GFA::CigarOperation.new([oplen, opcode])
    end
  end


  # Parses a CIGAR string representing an overlap and reverses it, i.e.
  # computes the CIGAR for the segments in reverse direction.
  # Return type: @see cigar_operations
  #
  # Example of conversion of a link to its reverse complement:
  #
  #   S1 + S2 + 2M1D3M
  #
  #   S1+  ACGACTGTGA
  #   S2+      CT-TGACGG
  #
  #   S2-  CCGTCA-AG
  #   S1-     TCACAGTCGT
  #
  #   S2 - S1 - 3M1I2M
  #
  # @return ["*"] if self == "*"
  # @return [Array<Integer, String(1)>] otherwise
  def reverse_cigar_operations
    return "*" if self == "*"
    self.cigar_operations.reverse.map do |oplen, opcode|
      if opcode == "I"
        opcode = "D"
      elsif opcode == "D"
        opcode = "I"
      end
      [oplen, opcode]
    end
  end

  # @see reverse_cigar_operation
  # @return ["*"] if self == "*"
  # @return [String] the reverse CIGAR, otherwise
  def reverse_cigar
    return "*" if self == "*"
    reverse_cigar_operations.flatten.join
  end

end

# Class representing a CIGAR operation
class GFA::CigarOperation < Array
  # @return [Integer] operation length
  def oplen
    self[0]
  end
  # @return [String] <i>(length: 1)</i>
  #   operation code
  def opcode
    self[1]
  end
end

class Array
  # @return [GFA::CigarOperation]
  def to_cigar_operation
    kind_of?(GFA::CigarOperation) ? self : GFA::CigarOperation.new(self)
  end
end

class String
  include GFA::CIGAR
end
