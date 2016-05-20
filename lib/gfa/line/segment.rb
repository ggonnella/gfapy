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

end
