class GFA::Line::Header < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#header-line
  # note: the field names were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type, /H/]
    ]

  OptfieldTypes = {
     "VN" => "Z", # Version number
    }

  def initialize(fields)
    super(fields, GFA::Line::Header::FieldRegexp,
          GFA::Line::Header::OptfieldTypes)
  end

end
