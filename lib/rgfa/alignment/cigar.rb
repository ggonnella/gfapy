RGFA::Alignment ||= Module.new

# Array of {RGFA::Alignment::CIGAR::Operation CIGAR operations}.
# Represents the contents of a CIGAR string.
# @tested_in api_alignment
class RGFA::Alignment::CIGAR < Array

  # Compute the CIGAR for the segments when these are switched.
  #
  # @example Computing the complement CIGAR
  #
  #   "2M1D3M".to_alignment.complement.to_s
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
    RGFA::Alignment::CIGAR.new(clone.reverse.map do |op|
      if op.code == :I or op.code == :S
        op.code = :D
      elsif op.code == :D or op.code == :N
        op.code = :I
      end
      op
    end)
  end

  # String representation of the CIGAR
  # @note no validation is performed, use #validate if required
  # @return [String] CIGAR string
  def to_s
    placeholder? ? "*" : (map(&:to_s).join)
  end

  # Validate the instance
  # @param version [Symbol] <i>(defaults to: +:gfa1+)</i> if :gfa2,
  #   then only CIGAR codes M/I/D/P are allowed, if :gfa1 all CIGAR codes
  # @raise [RGFA::ValueError] if a code is invalid or a length is negative
  # @raise [RGFA::TypeError] if a length is not an Integer or
  #   the array contains anything which is not interpretable as a
  #   cigar operation
  # @raise [RGFA::VersionError] if a wrong version is provided
  # @return [void]
  def validate(version: :gfa1)
    if ![:gfa1, :gfa2].include?(version)
      raise RGFA::VersionError, "Version unknown: #{version}"
    end
    any? do |op|
      begin
        op = op.to_cigar_operation
      rescue
        raise RGFA::TypeError, "Array contains elements which are "+
          "not CIGAR operations: #{self.inspect}"
      end
      op.validate(version: version)
    end
  end

  # @param valid [nil] ignored, for compatibility
  # @param version [nil] ignored, for compatibility
  # @return [RGFA::Alignment::CIGAR] self
  def to_alignment(valid: nil, version: :nil)
    self
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

  # Create a deep copy
  # @return [RGFA::Alignment::CIGAR]
  def clone
    RGFA::Alignment::CIGAR.new(map{|x|x.clone})
  end

  # @api private
  # @tested_in unit_alignment
  module API_PRIVATE

    # @return [RGFA::Alignment::CIGAR] self
    # @param valid [nil] ignored, for compatibility
    # @param version [nil] ignored, for compatibility
    def to_cigar(valid: nil, version: :nil)
      self
    end

    module ClassMethods

      # Parse a CIGAR string into an array of CIGAR operations.
      #
      # Each operation is represented by a {RGFA::Alignment::CIGAR::Operation},
      # i.e. a tuple of operation length and operation code.
      #
      # The operation code is one of MIDP for GFA2 or MIDPNSHX= for GFA1.
      # The additional operations allowed in GFA1 have an unclear meaning
      # in the context of GFA and should be avoided.
      #
      # @param version [Symbol] <i>(defaults to: +gfa1+)</i> if +:gfa2+,
      #   then only CIGAR codes M/I/D/P are allowed, if +:gfa1+ all CIGAR codes
      # @param valid [Boolean] <i>(defaults to: +false+)</i> if +true+,
      #   the string is guaranteed to be valid
      # @raise [RGFA::FormatError] if the string is not a valid CIGAR string
      # @raise [RGFA::VersionError] if a wrong version is provided
      # @return [RGFA::Alignment::CIGAR]
      def from_string(str, valid: false, version: :gfa1)
        a = RGFA::Alignment::CIGAR.new
        unless valid
          case version
          when :gfa1
            if str !~ /^([0-9]+[MIDPNSHX=])+$/
              raise RGFA::FormatError,
              "The string #{str} does not represent a valid CIGAR string"
            end
          when :gfa2
            if str !~ /^([0-9]+[MIDP])+$/
              raise RGFA::FormatError,
              "The string #{str} does not represent a valid GFA2 CIGAR string"
            end
          else
            raise RGFA::VersionError, "Version unknown: #{version}"
          end
        end
        str.scan(/[0-9]+[MIDPNSHX=]/).each do |op|
          len = op[0..-2].to_i
          code = op[-1..-1].to_sym
          a << RGFA::Alignment::CIGAR::Operation.new(len, code)
        end
        return a
      end

    end

  end
  include API_PRIVATE
  extend API_PRIVATE::ClassMethods

end

# An operation in a CIGAR string
# @tested_in api_alignment
class RGFA::Alignment::CIGAR::Operation

  # @!attribute [rw] len
  #   @return [Integer > 0] operation length
  attr_accessor :len

  # @!attribute [rw] code
  #   @return [RGFA::Alignment::CIGAR::Operation::CODE] operation code
  attr_accessor :code

  # CIGAR operation code
  CODE_GFA1_ONLY = [:S, :H, :N, :X, :"="]
  CODE_GFA1_GFA2 = [:M, :I, :D, :P]
  CODE = CODE_GFA1_ONLY + CODE_GFA1_GFA2

  # @param len [Integer] length of the operation
  # @param code [RGFA::Alignment::CIGAR::Operation::CODE] code of the operation
  def initialize(len, code)
    @len = len
    @code = code
  end

  # The string representation of the operation
  # @note no validation is performed, use #validate if required
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
  # @param version [Symbol] <i>(defaults to: +:gfa1+)</i> if :gfa2,
  #   then only CIGAR codes M/I/D/P are allowed, if :gfa1 all CIGAR codes
  # @raise [RGFA::ValueError] if the code is invalid or the length is negative
  # @raise [RGFA::TypeError] if the length is not an Integer
  # @raise [RGFA::VersionError] if a wrong version is provided
  # @return [void]
  def validate(version: :gfa1)
    if ![:gfa1, :gfa2].include?(version)
      raise RGFA::VersionError, "Version unknown: #{version}"
    end
    begin
      len = Integer(@len)
    rescue
      raise RGFA::TypeError, "CIGAR operation: #{self.inspect}\n"+
        "CIGAR length cannot be casted to Integer (class: #{len.class})"
    end
    begin
      code = @code.to_sym
    rescue
      raise RGFA::TypeError, "CIGAR operation: #{self.inspect}\n"+
        "CIGAR code cannot be casted to symbol (class: #{code.class})"
    end
    if len < 0
      raise RGFA::ValueError,
        "Length of CIGAR operation #{self} is invalid (#{len})"
    elsif RGFA::Alignment::CIGAR::Operation::CODE_GFA1_ONLY.include?(code)
      if version == :gfa2
        raise RGFA::ValueError, "CIGAR operation: #{self.inspect}\n"+
          "CIGAR code is not supported in GFA2: #{code}"
      end
    elsif !RGFA::Alignment::CIGAR::Operation::CODE_GFA1_GFA2.include?(code)
      raise RGFA::ValueError, "CIGAR operation: #{self.inspect}\n"+
        "Invalid CIGAR code found: #{code}"
    end
  end

  # @api private
  # @tested_in unit_alignment
  module API_PRIVATE
    # @return [RGFA::Alignment::CIGAR::Operation] self
    def to_cigar_operation
      self
    end
  end
  include API_PRIVATE

end

class Array

  # @api private
  # @tested_in unit_alignment
  module API_PRIVATE
    # Create a {RGFA::Alignment::CIGAR} instance from the content of the array.
    # @param valid [nil] ignored, for compatibility
    # @param version [nil] ignored, for compatibility
    # @return [RGFA::Alignment::CIGAR]
    def to_cigar(valid: nil, version: nil)
      RGFA::Alignment::CIGAR.new(self)
    end

    # Create a {RGFA::Alignment::CIGAR::Operation} instance
    # from the array content
    # @return [RGFA::Alignment::CIGAR::Operation]
    def to_cigar_operation
      RGFA::Alignment::CIGAR::Operation.new(Integer(self[0]), self[1].to_sym)
    end
  end
  include API_PRIVATE

end

class String

  # @api private
  # @tested_in unit_alignment
  module API_PRIVATE
    # Parse CIGAR string
    # @return [RGFA::Alignment::CIGAR,RGFA::Alignment::Placeholder]
    #    CIGAR or Placeholder (if +*+)
    # @param valid [Boolean] <i>(defaults to: +false+)</i> if +true+,
    #   the string is guaranteed to be valid
    # @param version [Symbol] <i>(defaults to: +:gfa1+)</i> if :gfa2,
    #   then only CIGAR codes M/I/D/P are allowed, if :gfa1 all CIGAR codes
    # @raise [RGFA::ValueError] if the string is not a valid CIGAR string
    # @raise [RGFA::VersionError] if a wrong version is provided
    def to_cigar(valid: false, version: :gfa1)
      if placeholder?
        return RGFA::Alignment::Placeholder.new
      else
        return RGFA::Alignment::CIGAR.from_string(self, valid: valid,
                                                  version: version)
      end
    end
  end
  include API_PRIVATE

end
