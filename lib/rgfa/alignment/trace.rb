RGFA::Alignment ||= Module.new

# Array of trace points.
#
# A trace is a list of integers, each giving the number of characters
# in the second segment to align to the next TS characters in the first
# segment.
#
# TS is either the default spacing given in the header line TS tag,
# or the the spacing given in the TS tag on the line of the edge.
#
# Note: a complement operation such as for CIGARs cannot be defined
# for a trace, without computing the alignment.
#
# @tested_in api_alignment
class RGFA::Alignment::Trace < Array

  # Validate the numeric array
  #
  # @param ts [Integer,nil] <it>(defaults to: +nil+)<it> trace spacing; if an
  #   integer is specified, it will be checked that all values are < +ts+; if
  #   +nil+, then this check is skipped
  #
  # @raise [RGFA::TypeError] if the array contains non-integer values
  # @raise [RGFA::ValueError] if the array contains values < 0 or > +ts+
  #
  # @return [void]
  #
  def validate(ts: nil)
    each do |e|
      if !e.kind_of?(Integer)
        raise RGFA::TypeError,
          "Trace contains non-integer values (#{e} found)\n"+
          "Content: #{inspect}"
      end
      if e < 0
        raise RGFA::ValueError,
          "Trace contains value < 0 (#{e} found)\n"+
          "Content: #{inspect}"
      end
      if !ts.nil? and e > ts
        raise RGFA::ValueError,
          "Trace contains value > TS (#{e} found, TS=#{ts})\n"+
        "Content: #{inspect}"
      end
    end
  end

  def to_s
    placeholder? ? "*" : (each(&:to_s).join(","))
  end

  # @param valid [nil] ignored, for compatibility
  # @param version [nil] ignored, for compatibility
  # @return [RGFA::Alignment::CIGAR] self
  def to_alignment(valid: nil, version: :nil)
    self
  end

  def complement
    return RGFA::Alignment::Placeholder.new
  end

  # @api private
  # @tested_in unit_alignment
  module API_PRIVATE

    # @return [RGFA::Alignment::Trace] self
    def to_trace
      self
    end

    module ClassMethods

      # @return [RGFA::Alignment::Trace] trace from trace string representation
      # @raise [RGFA::FormatError] if after splitting by comma, some elements
      #   are not integers
      def from_string(str)
        begin
          RGFA::Alignment::Trace.new(str.split(",").map{|i|Integer(i)})
        rescue
          raise RGFA::FormatError,
            "'#{str}' is not a valid string representing a trace"
        end
      end

    end

  end
  include API_PRIVATE
  extend API_PRIVATE::ClassMethods

end

class String

  # @api private
  # @tested_in unit_alignment
  module API_PRIVATE

    # Parse trace string
    # @return [RGFA::Alignment::Trace]
    # @raise [RGFA::FormatError] if the string is not a valid trace string
    def to_trace
      RGFA::Alignment::Trace.from_string(self)
    end

  end
  include API_PRIVATE

end
