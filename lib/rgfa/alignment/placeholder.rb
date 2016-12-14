require_relative "../placeholder"

RGFA::Alignment ||= Module.new

# Placeholder for alignments fields
class RGFA::Alignment::Placeholder < RGFA::Placeholder

  # For compatibility with CIGAR#complement.
  # @return [self]
  def complement
    self
  end

  # For compatibility with the +to_alignment+ method of other classes
  # (CIGAR, Trace, String, Array).
  # @param valid [nil] ignored, for compatibility
  # @param version [nil] ignored, for compatibility
  # @return [RGFA::Alignment::CIGAR] self
  def to_alignment(valid: nil, version: :nil)
    self
  end

  # @api private
  module API_PRIVATE

    # For compatibility with the +to_cigar+ method of other classes
    # @return [RGFA::Alignment::Placeholder] self
    # @param valid [nil] ignored, for compatibility
    # @param version [nil] ignored, for compatibility
    def to_cigar(valid: nil, version: :nil)
      self
    end

    # For compatibility with the +to_trace+ method of other classes
    # @return [RGFA::Alignment::Placeholder] self
    def to_trace
      self
    end

  end
  include API_PRIVATE

end
