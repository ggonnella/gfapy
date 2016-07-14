# A path line of a RGFA file
class RGFA::Line::Path < RGFA::Line

  RECORD_TYPE = :P
  REQFIELDS = [:path_name, :segment_names, :cigars]
  PREDEFINED_OPTFIELDS = []
  DATATYPE = {
    :path_name => :lbl,
    :segment_names => :lbs,
    :cigars => :cgs,
  }

  define_field_methods!

  # @note The field names are derived from the RGFA specification at:
  #   https://github.com/pmelsted/RGFA-spec/blob/master/RGFA-spec.md#path-line
  #   and were made all downcase with _ separating words;
  #   the cigar and segment_name regexps and name were changed to better
  #   implement what written in the commentaries of the specification
  #   (i.e. name pluralized and regexp changed to a comma-separated list
  #   for segment_name of segment names and orientations and for cigar of
  #   CIGAR strings);

  # @return [Symbol] name of the path as symbol
  def to_sym
    name.to_sym
  end

end
