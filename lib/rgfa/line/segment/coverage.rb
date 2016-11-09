module RGFA::Line::Segment::Coverage

  # @!macro [new] coverage
  #   The coverage computed from a count_tag.
  #   If unit_length is provided then: count/(length-unit_length+1),
  #   otherwise: count/length.
  #   The latter is a good approximation if length >>> unit_length.
  #   @param [Symbol] count_tag <i>(defaults to +:RC+)</i>
  #     integer tag storing the count, usually :KC, :RC or :FC
  #   @param [Integer] unit_length the (average) length of a read (for
  #     :RC), fragment (for :FC) or k-mer (for :KC)
  #   @return [Integer] coverage, if count_tag and length are defined
  # @return [nil] otherwise
  # @see #coverage!
  def coverage(count_tag: :RC, unit_length: 1)
    if tagnames.include?(count_tag) and self.length
      return (self.get(count_tag).to_f)/(self.length-unit_length+1)
    else
      return nil
    end
  end

  # @see #coverage
  # @!macro coverage
  # @raise [RGFA::NotFoundError] if segment does not have count_tag
  # @!macro length_needed
  def coverage!(count_tag: :RC, unit_length: 1)
    c = coverage(count_tag: count_tag, unit_length: unit_length)
    if c.nil?
      self.length!
      raise RGFA::NotFoundError,
        "Tag #{count_tag} undefined for segment #{name}"
    else
      return c
    end
  end

end
