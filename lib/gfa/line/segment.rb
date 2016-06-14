class GFA::Line::Segment < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#segment-line
  # note: the field names were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type, /S/],
     [:name,        /[!-)+-<>-~][!-~]*/], # Segment name
     [:sequence,    /\*|[A-Za-z=.]+/]     # The nucleotide sequence
    ]

  OptfieldTypes = {
     "LN" => "i", # Segment length
     "RC" => "i", # Read count
     "FC" => "i", # Fragment count
     "KC" => "i", # k-mer count
    }

  # @param [Array<String>] fields
  # @param [boolean] validate <it>(default: +true+>)</it>
  # @return [GFA::Line::Link]
  def initialize(fields, validate: true)
    super(fields, GFA::Line::Segment::FieldRegexp,
          GFA::Line::Segment::OptfieldTypes, validate: validate)
    validate_length! if validate
  end

  # @raise if sequence length and LN tag are not consistent.
  def validate_length!
    if sequence != "*" and optional_fieldnames.include?(:LN)
      if self.LN != sequence.length
        raise "Length in LN tag (#{self.LN}) "+
          "is different from length of sequence field (#{sequence.length})"
      end
    end
  end

  # @return [Integer] value of LN tag, if segment has LN tag
  # @return [Integer] sequence length if no LN and sequence not "*"
  # @return [nil] if sequence is "*"
  def length
    if self.LN
      self.LN
    elsif sequence != "*"
      sequence.length
    else
      nil
    end
  end

  # @see length
  # @raise if not LN and sequence is "*"
  def length!
    l = self.length()
    raise "No length information available" if l.nil?
    return l
  end

  # The coverage computed from a count_tag.
  # If unit_length is provided then: count/(length-unit_length+1),
  # otherwise: count/length.
  # The latter is a good approximation if length >>> unit_length.
  #
  # @param [Symbol] count_tag integer tag storing the count, usually
  #   :KC, :RC or :FC
  # @param [Integer] unit_length the (average) length of a read (for
  #   :RC), fragment (for :FC) or k-mer (for :KC)
  #
  # @return [Integer] coverage, if count_tag exists
  # @return [nil] otherwise
  def coverage(count_tag: :RC, unit_length: 1)
    if optional_fieldnames.include?(count_tag) and self.length
      return (self.send(count_tag).to_f)/(self.length-unit_length+1)
    else
      return nil
    end
  end

  # @see coverage
  # @raise if segment does not have count_tag
  # @raise if segment does not have LN and sequence is "*"
  def coverage!(count_tag: :RC, unit_length: 1)
    c = coverage(count_tag: count_tag, unit_length: unit_length)
    if c.nil?
      self.length!
      raise "Tag #{count_tag} undefined for segment #{name}"
    else
      return c
    end
  end

  # @return string representation of the segment
  # @param [boolean] without_sequence if false output "*" instead of sequence
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
