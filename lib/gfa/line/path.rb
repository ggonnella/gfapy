class GFA::Line::Path < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#path-line
  # note: the field names were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type,  /P/],
     [:from,         /[!-)+-<>-~][!-~]*/], # Path name
     # note: the cigar and segment_name regexps were changed to better
     #       implement what written in the commentaries
     #       (i.e. a comma-separated list
     #        for segment_name of segment names and orientations
     #        and for cigar of CIGAR strings)
     [:segment_name, /[!-)+-<>-~][!-~]*[+-](,[!-)+-<>-~][!-~]*[+-])*/],
                      # A comma-separated list of segment names and orientations
     [:cigar,        /\*|([0-9]+[MIDNSHPX=])+((,[0-9]+[MIDNSHPX=])+)*/]
                                   # A comma-separated list of CIGAR strings
    ]

  OptfieldTypes = {}

  def initialize(fields)
    super(fields, GFA::Line::Path::FieldRegexp,
          GFA::Line::Path::OptfieldTypes)
  end

  def split_segment_names
    split_comma_separated(self.segment_name, /(.*)([\+-])/)
  end

  def split_cigar
    split_comma_separated(self.cigar, /([0-9]+)([MIDNSHPX=])/)
  end

  private

  def split_comma_separated(str_to_split, elems_regex)
    elems = str_to_split.split(",")
    retval = []
    elems.each do |elem|
      elem =~ elems_regex
      raise TypeError if $1.nil? # this should be impossible
      retval << [$1, $2]
    end
    return retval
  end
end
