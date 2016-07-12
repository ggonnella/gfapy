# A segment line of a RGFA file
class RGFA::Line::Segment < RGFA::Line

  RECORD_TYPE = "S"
  REQFIELDS = [:name, :sequence]
  PREDEFINED_OPTFIELDS = [:LN, :RC, :FC, :KC]
  DATATYPE = {
    :name => :lbl,
    :sequence => :seq,
    :LN => :i,
    :RC => :i,
    :FC => :i,
    :KC => :i
  }

  # @raise if sequence length and LN tag are not consistent.
  def validate_length!
    if sequence != "*" and optional_fieldnames.include?(:LN)
      if self.LN != sequence.length
        raise "Length in LN tag (#{self.LN}) "+
          "is different from length of sequence field (#{sequence.length})"
      end
    end
  end

  # @!macro [new] length
  #   @return [Integer] value of LN tag, if segment has LN tag
  #   @return [Integer] sequence length if no LN and sequence not "*"
  # @return [nil] if sequence is "*"
  # @see #length!
  def length
    if self.LN
      self.LN
    elsif sequence != "*"
      sequence.length
    else
      nil
    end
  end

  # @!macro length
  # @!macro [new] length_needed
  #   @raise [RGFA::Line::Segment::UndefinedLengthError] if not an LN tag and the
  #     sequence is "*"
  # @see #length
  def length!
    l = self.length()
    raise RGFA::Line::Segment::UndefinedLengthError,
      "No length information available" if l.nil?
    return l
  end

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
    if optional_fieldnames.include?(count_tag) and self.length
      return (self.send(count_tag).to_f)/(self.length-unit_length+1)
    else
      return nil
    end
  end

  # @see #coverage
  # @!macro coverage
  # @raise [RGFA::Line::TagMissingError] if segment does not have count_tag
  # @!macro length_needed
  def coverage!(count_tag: :RC, unit_length: 1)
    c = coverage(count_tag: count_tag, unit_length: unit_length)
    if c.nil?
      self.length!
      raise RGFA::Line::TagMissingError,
        "Tag #{count_tag} undefined for segment #{name}"
    else
      return c
    end
  end

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

  # @return [Symbol] name of the segment as symbol
  def to_sym
    name.to_sym
  end

  private

  def validate_record_type_specific_info!
    validate_length!
  end

end

# Error raised if length of segment cannot be computed
class RGFA::Line::Segment::UndefinedLengthError < ArgumentError; end
