require_relative "error.rb"

# Array of {RGFA::CIGAR::Operation CIGAR operations}.
# Represents the contents of a CIGAR string.
class RGFA::CIGAR < Array

  # Compute the CIGAR for the segments when these are switched.
  #
  # @example Computing the complement CIGAR
  #
  #   RGFA::CIGAR.from_string("2M1D3M").complement.to_s
  #   # => "3M1I2M"
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
  # @return [RGFA::CIGAR]
  def complement
    reverse.map do |op|
      if op.code == :I
        op.code = :D
      elsif op.code == :D
        op.code = :I
      end
      op
    end
  end

  # Parse a CIGAR string into an array of CIGAR operations.
  #
  # Each operation is represented by a {RGFA::CIGAR::Operation},
  # i.e. a tuple of operation length and operation
  # symbol (one of MIDP).
  #
  # Deprecation warning: the GFA1 specification does not forbid the
  # other operation symbols (NSHX=); these are not allowed in GFA2 and their
  # use is deprecated.
  #
  # @return [RGFA::CIGAR]
  # @raise [RGFA::CIGAR::ValueError] if the string is not a valid CIGAR string
  def self.from_string(str)
    a = RGFA::CIGAR.new
    raise RGFA::CIGAR::ValueError if str !~ /^([0-9]+[MIDNSHPX=])+$/
    str.scan(/[0-9]+[MIDNSHPX=]/).each do |op|
      len = op[0..-2].to_i
      code = op[-1..-1].to_sym
      a << RGFA::CIGAR::Operation.new(len, code)
    end
    return a
  end

  # String representation of the CIGAR
  # @return [String] CIGAR string
  def to_s
    map(&:to_s).join
  end

  # Validate the instance
  # @raise if any component of the CIGAR array is invalid.
  # @return [void]
  def validate!
    any? do |op|
      op.to_cigar_operation.validate!
    end
  end

  # @return [RGFA::CIGAR] self
  def to_cigar
    self
  end

  # @param allow_traces [Boolean] ignored, for compatibility only
  # @return [RGFA::CIGAR] self
  def to_alignment(allow_traces = true)
    self
  end

  # Create a copy
  # @return [RGFA::CIGAR]
  def clone
    map{|x|x.clone}
  end

end

# Exception raised by invalid CIGAR string content
class RGFA::CIGAR::ValueError < RGFA::Error; end

# An operation in a CIGAR string
class RGFA::CIGAR::Operation

  # @!attribute [rw] len
  #   @return [Integer > 0] operation length
  attr_accessor :len

  # @!attribute [rw] code
  #   @return [RGFA::CIGAR::Operation::CODE] operation code
  attr_accessor :code

  # CIGAR operation code
  CODE = [:M, :I, :D, :N, :S, :H, :P, :X, :"="]

  # @param len [Integer] length of the operation
  # @param code [RGFA::CIGAR::Operation::CODE] code of the operation
  def initialize(len, code)
    @len = len
    @code = code
  end

  # The string representation of the operation
  # @return [String]
  def to_s
    "#{len}#{code}"
  end

  # Compare two operations
  # @return [Boolean]
  def ==(other)
    other.len == len and other.code == code
  end

  # Validate the operation
  # @return [void]
  # @raise [RGFA::CIGAR::ValueError] if the code is invalid or the length is not
  #   an integer larger than zero
  def validate!
    if Integer(len) <= 0 or
         !RGFA::CIGAR::Operation::CODE.include?(code)
      raise RGFA::CIGAR::ValueError
    end
  end

  # @return [RGFA::CIGAR::Operation] self
  def to_cigar_operation
    self
  end
end

class Array
  # Create a {RGFA::CIGAR} instance from the content of the array.
  # @return [RGFA::CIGAR]
  def to_cigar
    RGFA::CIGAR.new(self)
  end
  # Create a {RGFA::CIGAR::Operation} instance from the content of the array.
  # @return [RGFA::CIGAR::Operation]
  def to_cigar_operation
    RGFA::CIGAR::Operation.new(Integer(self[0]), self[1].to_sym)
  end
end

class String
  # Parse CIGAR string
  # @return [RGFA::CIGAR,RGFA::Placeholder] CIGAR or Placeholder (if +*+)
  # @raise [RGFA::CIGAR::ValueError] if the string is not a valid CIGAR string
  def to_cigar
    if self == "*"
      return RGFA::Placeholder.new
    else
      return RGFA::CIGAR.from_string(self)
    end
  end
end

