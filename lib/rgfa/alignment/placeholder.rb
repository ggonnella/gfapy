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

  # For compatibility with the +to_cigar+ method of other classes
  # @api private
  # @return [RGFA::Alignment::CIGAR] self
  # @param valid [nil] ignored, for compatibility
  # @param version [nil] ignored, for compatibility
  # @api private
  def to_cigar(valid: nil, version: :nil)
    self
  end


end
