module RGFA::Line::Segment::LengthGFA1

  # @!macro [new] length
  #   @return [Integer] value of LN tag, if segment has LN tag
  #   @return [Integer] sequence length if no LN and sequence not "*"
  # @return [nil] if sequence is "*"
  # @see #length!
  def length
    if self.LN
      self.LN
    elsif !sequence.placeholder? and !sequence.kind_of?(RGFA::Placeholder)
      sequence.length
    else
      nil
    end
  end

  # @!macro length
  # @!macro [new] length_needed
  #   @raise [RGFA::NotFoundError] if not an LN tag and
  #     the sequence is "*"
  # @see #length
  def length!
    l = self.length()
    raise RGFA::NotFoundError,
      "No length information available" if l.nil?
    return l
  end

  # @raise [RGFA::InconsistencyError]
  #    if sequence length and LN tag are not consistent.
  def validate_length!
    if !sequence.placeholder? and tagnames.include?(:LN)
      if self.LN != sequence.length
        raise RGFA::InconsistencyError,
          "Length in LN tag (#{self.LN}) "+
          "is different from length of sequence field (#{sequence.length})"
      end
    end
  end

  private

  def validate_record_type_specific_info!
    validate_length!
  end

end

