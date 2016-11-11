RGFA::Alignment = Module.new

require_relative "error"
require_relative "alignment/placeholder"
require_relative "alignment/cigar"
require_relative "alignment/trace"

class String
  # Parses an alignment field
  # @param allow_traces [Boolean] if false, then only CIGARs or Placeholders
  #   are considered valid; if true, also trace alignments
  # @return [RGFA::Alignment::CIGAR, RGFA::Alignment::Trace, RGFA::AlignentPlaceholder]
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
          return RGFA::Alignment::Placeholder.new
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
  # @return [RGFA::Alignment::CIGAR, RGFA::Alignment::Trace]
  def to_alignment(allow_traces = true)
    if self.empty?
      return RGFA::Alignment::Placeholder.new
    elsif self[0].kind_of?(Integer)
      if allow_traces
        return RGFA::Alignment::Trace.new(self)
      else
        raise RGFA::FormatError,
          "Trace alignments are not allowed in GFA1: #{self.inspect}"
      end
    elsif self[0].kind_of?(RGFA::Alignment::CIGAR::Operation)
      return RGFA::Alignment::CIGAR.new(self)
    else
      raise RGFA::FormatError,
        "Array does not represent a valid alignment field: #{self.inspect}"
    end
  end
end
