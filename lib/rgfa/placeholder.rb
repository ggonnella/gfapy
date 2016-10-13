# A placeholder is used in mandatory fields when a value is not specified.
# Its string representation is an asterisk (+*+).
class RGFA::Placeholder
  # @return [String] string representation (+*+)
  def to_s
    "*"
  end

  # For compatibility with CIGAR#complement.
  # @return [self]
  def complement
    self
  end

  # For compatibility with the to_alignment method of other classes
  # (CIGAR, Trace, String, Array).
  # @param allow_traces [Boolean] ignored
  # @return [self]
  def to_alignment(allow_traces = true)
    self
  end

  # A placeholder is always empty
  # return [true]
  def empty?
    true
  end

  # A placeholder is always valid
  # return [void]
  def validate!
  end

  # For compatibility with String#rc (RGFA::Sequence module)
  # @return [self]
  def rc
    self
  end

  # Length/size of a placeholder is always 0
  # @return [self]
  def length
    0
  end

  alias_method :size, :length

  # Any cut of the placeholder returns the placeholder itself
  # @param anything [Object] ignored
  # @return [self]
  def [](*anything)
    self
  end

  # Adding the placeholder to anything returns the placeholder itself
  # @param anything [Object] ignored
  # @return [self]
  def +(*anything)
    self
  end

end
