require_relative "../segment"

module RGFA::Line::Segment::WriterWoSequence

  # @return string representation of the segment
  # @param [Boolean] without_sequence if +true+, output "*" instead of sequence
  def to_s(without_sequence: false)
    if !without_sequence
      return super()
    else
      saved = self.sequence
      self.sequence = "*"
      retval = super()
      self.sequence = saved
      return retval
    end
  end

end
