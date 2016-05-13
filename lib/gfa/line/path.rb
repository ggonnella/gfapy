class GFA::Line::Path < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#path-line
  # note: the field names were made all downcase with _ separating words
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

  def split_segment_names
    path_segments = gfa_line.segment_name.split(",")
    if path_segments.size == 1
      raise TypeError, "Path contains only one segment:\n#{gfa_line}"
    end
    retval = []
    path_segments.each do |elem|
      elem =~ /(.*)([\+-])/
      if $1.nil?
        raise TypeError, "Segment name list format error:\n#{gfa_line}"
      end
      retval << [$1, $2]
    end
    return retval
  end
end
