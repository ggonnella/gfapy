class GFA::Line::Path < GFA::Line

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#path-line
  # note: the field names were made all downcase with _ separating words
  FieldRegexp = [
     [:record_type,  /P/],
     [:path_name,    /[!-)+-<>-~][!-~]*/], # Path name
     # note: the cigar and segment_name regexps were changed to better
     #       implement what written in the commentaries
     #       (i.e. a comma-separated list
     #        for segment_name of segment names and orientations
     #        and for cigar of CIGAR strings);
     [:segment_name, /[!-)+-<>-~][!-~]*[+-](,[!-)+-<>-~][!-~]*[+-])*/],
                      # A comma-separated list of segment names and orientations
     [:cigar,        /\*|([0-9]+[MIDNSHPX=])+((,[0-9]+[MIDNSHPX=])+)*/]
                      # A comma-separated list of CIGAR strings
    ]

  FieldCast =
    { :segment_name => lambda {|e| split_segment_name(e) },
      :cigar        => lambda {|e| split_cigar(e) } }

  OptfieldTypes = {}

  def initialize(fields)
    super(fields, GFA::Line::Path::FieldRegexp,
          GFA::Line::Path::OptfieldTypes,
          GFA::Line::Path::FieldCast)
  end

  private

  def self.split_cigar(c)
    c.split(",").map{|str|str.cigar_operations}
  end

  def self.split_segment_name(sn)
    retval = []
    sn.split(",").each do |elem|
      elem =~ /(.*)([\+-])/
      raise TypeError if $1.nil? # this should be impossible
      retval << [$1, $2]
    end
    return retval
  end

end
