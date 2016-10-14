#
# Methods to parse and handle alignment field contents
#
module RGFA::Alignment; end

class String
  # Parses an alignment field
  # @param allow_traces [Boolean] if false, then only CIGARs or Placeholders
  #   are considered valid; if true, also trace alignments
  # @return [RGFA::Cigar, RGFA::Trace, RGFA::AlignentPlaceholder]
  # @raise [RGFA::FieldParser::FormatError] if the content of the
  #   field cannot be parsed
  def to_alignment(allow_traces = true)
    first = true
    each_char do |char|
      if first
        if char =~ /\d/
          first = false
          next
        elsif char == "*" and size == 1
          return RGFA::Placeholder.new
        end
      else
        if char =~ /\d/
          next
        elsif char == ","
          if allow_traces
            return self.to_trace
          else
            raise RGFA::FormatError,
              "Trace alignments are not allowed in GFA1: #{self.inspect}"
          end
        elsif char =~ /[MIDP]/
          return self.to_cigar
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
  # @param allow_traces [Boolean] if false, then only CIGARs or Placeholders
  #   are considered valid; if true, also trace alignments
  # @return [RGFA::Cigar, RGFA::Trace]
  def to_alignment(allow_traces = true)
    if self.empty?
      return RGFA::Placeholder.new
    elsif self[0].kind_of?(Integer)
      if allow_traces
        return RGFA::Trace.new(self)
      else
        raise RGFA::FormatError,
          "Trace alignments are not allowed in GFA1: #{self.inspect}"
      end
    elsif self[0].kind_of?(RGFA::CIGAR::Operation)
      return RGFA::CIGAR.new(self)
    else
      raise RGFA::FormatError,
        "Array does not represent a valid alignment field: #{self.inspect}"
    end
  end
end
