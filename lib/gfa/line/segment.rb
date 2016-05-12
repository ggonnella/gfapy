class GFA::Line::Segment < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#segment-line
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
  end

end
