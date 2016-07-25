require_relative "error.rb"

# Array of CIGAR operations representing the content of a cigar field
class RGFA::CIGAR < Array

  # Computes the CIGAR for the segments in reverse direction.
  #
  # @example
  #
  #   RGFA::CIGAR.from_string("2M1D3M").reverse.to_s # => "3M1I2M"
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
  # @return [RGFA::CIGAR] (empty if CIGAR string is *)
  def reverse
    super.map do |op|
      if op.code == :I
        op.code = :D
      elsif op.code == :D
        op.code = :I
      end
      op
    end
  end

  # Parses a CIGAR string into an array of cigar operations,
  # each represented by a tuple of operation length and operation
  # symbol (one of MIDNSHPX=).
  #
  # @return [RGFA::CIGAR] (empty if string is *)
  # @raise [RGFA::CIGAR::ValueError] if the string is not a valid CIGAR string
  def self.from_string(str)
    a = RGFA::CIGAR.new
    return [] if str == "*"
    raise RGFA::CIGAR::ValueError if str !~ /^([0-9]+[MIDNSHPX=])+$/
    str.scan(/[0-9]+[MIDNSHPX=]/).each do |op|
      len = op[0..-2].to_i
      code = op[-1..-1].to_sym
      a << RGFA::CIGAR::Operation.new(len, code)
    end
    return a
  end

  # @return [String] CIGAR string
  def to_s
    if empty?
      return "*"
    else
      map(&:to_s).join
    end
  end

  # @return [RGFA::CIGAR] self
  def to_cigar
    self
  end

end

class Array
  def to_cigar
    RGFA::CIGAR.new(self)
  end
end

class String
  # Parse CIGAR string and return an array of CIGAR operations
  # @return [RGFA::CIGAR] CIGAR operations (empty if string is "*")
  # @raise [RGFA::CIGAR::ValueError] if the string is not a valid CIGAR string
  def to_cigar
    RGFA::CIGAR.from_string(self)
  end
end

# Exception raised by invalid cigar string content
class RGFA::CIGAR::ValueError < RGFA::Error; end

RGFA::CIGAR::Operation = Struct.new(:len, :code)

class RGFA::CIGAR::Operation
  # The string representation of the operation
  # @return [String]
  def to_s
    "#{len}#{code}"
  end
end
