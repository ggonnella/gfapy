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

  def initialize(fields)
    super(fields, GFA::Line::Segment::FieldRegexp,
          GFA::Line::Segment::OptfieldTypes)
    validate_length!
  end

  def validate_length!
    if sequence != "*" and optional_fieldnames.include?(:LN)
      if self.LN != sequence.length
        raise "Length in LN tag (#{self.LN}) "+
          "is different from length of sequence field (#{sequence.length})"
      end
    end
  end

  def length
    if self.LN
      self.LN
    elsif sequence != "*"
      sequence.length
    else
      nil
    end
  end

  def length!
    l = self.length()
    raise "No length information available" if l.nil?
    return l
  end

  def coverage(count_tag: :RC)
    if optional_fieldnames.include?(count_tag) and
        optional_fieldnames.include?(:LN)
      return (self.send(count_tag).to_f)/self.LN
    else
      return nil
    end
  end

  def coverage!(count_tag: :RC)
    c = coverage(count_tag: count_tag)
    if c.nil?
      [count_tag, :LN].each do |ct|
        if !optional_fieldnames.include?(ct)
          raise "Tag #{ct} undefined for segment #{name}"
        end
      end
    else
      return c
    end
  end

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
