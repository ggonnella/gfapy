RGFA::Alignment = Module.new

require_relative "error"
require_relative "alignment/placeholder"
require_relative "alignment/cigar"
require_relative "alignment/trace"

# @tested_in api_alignment
class String
  # Parses an alignment field
  # @param version [Symbol] if :gfa2, then CIGARs and placeholders
  #   are considered valid; if :gfa1, CIGARs (limited to MIDP),
  #   trace alignments and placeholders
  # @return [RGFA::Alignment::CIGAR, RGFA::Alignment::Trace,
  #          RGFA::Alignment::Placeholder]
  # @raise [RGFA::FormatError] if the content of the
  #   field cannot be parsed
  # @param valid [Boolean] <i>(defaults to: +false+)</i> if +true+,
  #   the string is guaranteed to be valid
  # @raise [RGFA::VersionError] if a wrong version is provided
  def to_alignment(version: :gfa2, valid: false)
    if ![:gfa1, :gfa2].include?(version)
      raise RGFA::VersionError, "Version unknown: #{version}"
    end
    first = true
    each_char do |char|
      if first
        if char =~ /\d/
          first = false
          next
        elsif placeholder?
          return RGFA::Alignment::Placeholder.new
        end
      else
        if char =~ /\d/
          next
        elsif char == ","
          if version == :gfa2
            t = self.to_trace
            t.validate if !valid
            return t
          else
            raise RGFA::FormatError,
              "Trace alignments are not allowed in GFA1: #{self.inspect}"
          end
        elsif char =~ /[MIDP]/ or (char =~ /[=XSHN]/ and version == :gfa1)
          return self.to_cigar(valid: valid, version: version)
        end
      end
      break
    end
    raise RGFA::FormatError,
      "Alignment field contains invalid data: #{self.inspect}"
  end
end

# @tested_in unit_alignment
class Array

  # @api private
  module API_PRIVATE

    # Convert an array to an appropriate Alignment instance
    #
    # @param version [Symbol] if +:gfa2+, then CIGARs and placeholders
    #   are considered valid; if +:gfa1+, CIGARs (limited to MIDP),
    #   trace alignments and placeholders
    # @param valid [Boolean] ignored, for compatibility
    #
    # @raise [RGFA::FormatError] if the content of the
    #   array cannot be interpreted as an alignment specification
    # @raise [RGFA::VersionError] if a wrong version is provided
    #
    # @return [RGFA::Alignment::CIGAR, RGFA::Alignment::Trace, RGFA::Alignment::Placeholder]
    #   an empty array is converted to a placeholder,
    #   an array of CIGAR operations to a CIGAR instance,
    #   an array of Integers to a Trace instance
    #
    def to_alignment(version: :gfa1, valid: nil)
      if ![:gfa1, :gfa2].include?(version)
        raise RGFA::VersionError, "Version unknown: #{version}"
      end
      if self.empty?
        return RGFA::Alignment::Placeholder.new
      elsif self[0].kind_of?(Integer)
        if version == :gfa2
          return RGFA::Alignment::Trace.new(self)
        else
          raise RGFA::VersionError,
            "Trace alignments are not allowed in GFA1: #{self.inspect}"
        end
      elsif self[0].kind_of?(RGFA::Alignment::CIGAR::Operation)
        return RGFA::Alignment::CIGAR.new(self)
      else
        raise RGFA::FormatError,
          "Array does not represent a valid alignment: #{self.inspect}"
      end
    end

  end
  include API_PRIVATE

end
