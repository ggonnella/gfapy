RGFA::Alignment = Module.new

require_relative "error"
require_relative "alignment/placeholder"
require_relative "alignment/cigar"
require_relative "alignment/trace"

class String
  # Parses an alignment field
  # @param version [Symbol] if :"2.0", then CIGARs and placeholders
  #   are considered valid; if :"1.0", CIGARs (limited to MIDP),
  #   trace alignments and placeholders
  # @return [RGFA::Alignment::CIGAR, RGFA::Alignment::Trace,
  #          RGFA::Alignment::Placeholder]
  # @raise [RGFA::FormatError] if the content of the
  #   field cannot be parsed
  # @param valid [Boolean] <i>(defaults to: +false+)</i> if +true+,
  #   the string is guaranteed to be valid
  # @raise [RGFA::VersionError] if a wrong version is provided
  def to_alignment(version: :"2.0", valid: false)
    if ![:"1.0", :"2.0"].include?(version)
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
          if version == :"2.0"
            t = self.to_trace
            t.validate! if !valid
            return t
          else
            raise RGFA::FormatError,
              "Trace alignments are not allowed in GFA1: #{self.inspect}"
          end
        elsif char =~ /[MIDP]/ or (char =~ /[=XSHN]/ and version == :"1.0")
          return self.to_cigar(valid: valid, version: version)
        end
      end
      break
    end
    raise RGFA::FormatError,
      "Alignment field contains invalid data: #{self.inspect}"
  end
end

class Array
  # Converts an alignment array into a specific array type
  # @return [RGFA::Alignment::CIGAR, RGFA::Alignment::Trace]
  # @param version [Symbol] if :"2.0", then CIGARs and placeholders
  #   are considered valid; if :"1.0", CIGARs (limited to MIDP),
  #   trace alignments and placeholders
  # @raise [RGFA::FormatError] if the content of the
  #   array cannot be parsed
  # @param valid [Boolean] ignored, for compatibility
  # @raise [RGFA::VersionError] if a wrong version is provided
  # @api private
  def to_alignment(version: :"1.0", valid: nil)
    if ![:"1.0", :"2.0"].include?(version)
      raise RGFA::VersionError, "Version unknown: #{version}"
    end
    if self.empty?
      return RGFA::Alignment::Placeholder.new
    elsif self[0].kind_of?(Integer)
      if version == :"2.0"
        return RGFA::Alignment::Trace.new(self)
      else
        raise RGFA::FormatError,
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
