RGFA::Alignment ||= Module.new

# Array of {RGFA::Alignment::CIGAR::Operation CIGAR operations}.
# Represents the contents of a CIGAR string.
class RGFA::Alignment::CIGAR < Array

  # Compute the CIGAR for the segments when these are switched.
  #
  # @example Computing the complement CIGAR
  #
  #   RGFA::Alignment::CIGAR.from_string("2M1D3M").complement.to_s
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
  # @return [RGFA::Alignment::CIGAR]
  def complement
    RGFA::Alignment::CIGAR.new(reverse.map do |op|
      if op.code == :I
        op.code = :D
      elsif op.code == :D or op.code == :N
        op.code = :I
      end
      op
    end)
  end

  # Parse a CIGAR string into an array of CIGAR operations.
  #
  # Each operation is represented by a {RGFA::Alignment::CIGAR::Operation},
  # i.e. a tuple of operation length and operation
  # symbol (one of MIDP).
  #
  # Deprecation warning: the GFA1 specification does not forbid the
  # other operation symbols (NSHX=); these are not allowed in GFA2 and their
  # use is deprecated.
  #
  # @return [RGFA::Alignment::CIGAR]
  # @param valid [Boolean] <i>(defaults to: +false+)</i> if +true+,
  #   the string is guaranteed to be valid
  # @raise [RGFA::FormatError] if the string is not a valid CIGAR string
  def self.from_string(str, valid: false)
    a = RGFA::Alignment::CIGAR.new
    unless valid
      if str !~ /^([0-9]+[MIDNSHPX=])+$/
        raise RGFA::FormatError
      end
    end
    str.scan(/[0-9]+[MIDNSHPX=]/).each do |op|
      len = op[0..-2].to_i
      code = op[-1..-1].to_sym
      a << RGFA::Alignment::CIGAR::Operation.new(len, code)
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

  # @return [RGFA::Alignment::CIGAR] self
  # @param valid [nil] ignored, for compatibility
  def to_cigar(valid: nil)
    self
  end

  # @param allow_traces [Boolean] ignored, for compatibility only
  # @return [RGFA::Alignment::CIGAR] self
  def to_alignment(allow_traces = true)
    self
  end

  # Create a copy
  # @return [RGFA::Alignment::CIGAR]
  def clone
    RGFA::Alignment::CIGAR.new(map{|x|x.clone})
  end

  # Lenght of the aligned substring on the reference sequence
  # (+from+ sequence for GFA1 links/containments;
  #  +sid1+ sequence for GFA2 edges)
  # @return [Integer] length of the aligned substring on the
  #   reference sequence
  def length_on_reference
    l = 0
    each do |op|
     if [:M, :"=", :X, :D, :N].include?(op.code)
       l += op.len
     end
    end
    return l
  end

  # Lenght of the aligned substring on the query sequence
  # (+to+ sequence for GFA1 links/containments;
  #  +sid2+ sequence for GFA2 edges)
  # @return [Integer] length of the aligned substring on the
  #   query sequence
  def length_on_query
    l = 0
    each do |op|
     if [:M, :"=", :X, :I, :S].include?(op.code)
       l += op.len
     end
    end
    return l
  end

end

# An operation in a CIGAR string
class RGFA::Alignment::CIGAR::Operation

  # @!attribute [rw] len
  #   @return [Integer > 0] operation length
  attr_accessor :len

  # @!attribute [rw] code
  #   @return [RGFA::Alignment::CIGAR::Operation::CODE] operation code
  attr_accessor :code

  # CIGAR operation code
  CODE = [:M, :I, :D, :N, :S, :H, :P, :X, :"="]

  # @param len [Integer] length of the operation
  # @param code [RGFA::Alignment::CIGAR::Operation::CODE] code of the operation
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
  # @raise [RGFA::ValueError] if the code is invalid or the length is not
  #   an integer larger than zero
  def validate!
    if Integer(len) <= 0 or
         !RGFA::Alignment::CIGAR::Operation::CODE.include?(code)
      raise RGFA::ValueError
    end
  end

  # @return [RGFA::Alignment::CIGAR::Operation] self
  def to_cigar_operation
    self
  end
end

class Array
  # Create a {RGFA::Alignment::CIGAR} instance from the content of the array.
  # @param valid [nil] ignored, for compatibility
  # @return [RGFA::Alignment::CIGAR]
  def to_cigar(valid: nil)
    RGFA::Alignment::CIGAR.new(self)
  end
  # Create a {RGFA::Alignment::CIGAR::Operation} instance from the content of the array.
  # @return [RGFA::Alignment::CIGAR::Operation]
  def to_cigar_operation
    RGFA::Alignment::CIGAR::Operation.new(Integer(self[0]), self[1].to_sym)
  end
end

class String
  # Parse CIGAR string
  # @return [RGFA::Alignment::CIGAR,RGFA::Alignment::Placeholder]
  #    CIGAR or Placeholder (if +*+)
  # @param valid [Boolean] <i>(defaults to: +false+)</i> if +true+,
  #   the string is guaranteed to be valid
  # @raise [RGFA::ValueError] if the string is not a valid CIGAR string
  def to_cigar(valid: false)
    if self == "*"
      return RGFA::Alignment::Placeholder.new
    else
      return RGFA::Alignment::CIGAR.from_string(self, valid: valid)
    end
  end
end

