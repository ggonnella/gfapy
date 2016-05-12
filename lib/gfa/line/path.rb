class GFA::Line::Path < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#path-line
  FieldRegexp = [
     [:record_type,  /P/],
     [:from,         /[!-)+-<>-~][!-~]*/], # Path name
     [:segment_name, /[!-)+-<>-~][!-~]*/],
                      # A comma-separated list of segment names and orientations
     [:cigar,        /\*|([0-9]+[MIDNSHPX=])+/]
                                   # A comma-separated list of CIGAR strings
    ]

  OptfieldTypes = {}

  def initialize(fields)
    super(fields, GFA::Line::Path::FieldRegexp,
          GFA::Line::Path::OptfieldTypes)
  end

end
