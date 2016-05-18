class GFA::Line::Link < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#link-line
  # note: the field names were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type, /L/],
     [:from,        /[!-)+-<>-~][!-~]*/], # name of segment
     [:from_orient, /\+|-/],              # orientation of From segment
     [:to,          /[!-)+-<>-~][!-~]*/], # name of segment
     [:to_orient,   /\+|-/],              # orientation of To segment
     [:overlap,     /\*|([0-9]+[MIDNSHPX=])+/] # CIGAR string describing overlap
    ]

  FieldCast =
    { :overlap => lambda {|e| e.cigar_operations} }

  OptfieldTypes = {
     "MQ" => "i", # Mapping quality
     "NM" => "i", # # mismatches/gaps
     "RC" => "i", # Read count
     "FC" => "i", # Fragment count
     "KC" => "i"  # k-mer count
    }

  def initialize(fields)
    super(fields,
          GFA::Line::Link::FieldRegexp,
          GFA::Line::Link::OptfieldTypes,
          GFA::Line::Link::FieldCast)
  end

end
