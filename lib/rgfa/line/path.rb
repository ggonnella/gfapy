# A path line of a RGFA file
class RGFA::Line::Path < RGFA::Line

  RECORD_TYPE = "P"

  # @note The field names are derived from the RGFA specification at:
  #   https://github.com/pmelsted/RGFA-spec/blob/master/RGFA-spec.md#path-line
  #   and were made all downcase with _ separating words;
  #   the cigar and segment_name regexps and name were changed to better
  #   implement what written in the commentaries of the specification
  #   (i.e. name pluralized and regexp changed to a comma-separated list
  #   for segment_name of segment names and orientations and for cigar of
  #   CIGAR strings);
  REQFIELD_DEFINITIONS = [
     [:path_name,     /[!-)+-<>-~][!-~]*/], # Path name
     [:segment_names, /[!-)+-<>-~][!-~]*[+-](,[!-)+-<>-~][!-~]*[+-])*/],
                      # A comma-separated list of segment names and orientations
     [:cigars,        /\*|([0-9]+[MIDNSHPX=])+((,[0-9]+[MIDNSHPX=])+)*/]
                      # A comma-separated list of CIGAR strings
    ]

  # Procedures for the conversion of selected required fields to Ruby types
  REQFIELD_CAST =
    { :segment_names => lambda {|e| split_segment_names(e) },
      :cigars        => lambda {|e| split_cigars(e) } }

  # Predefined optional fields
  OPTFIELD_TYPES = {}

  # @return [Symbol] name of the path as symbol
  def to_sym
    name.to_sym
  end

  private

  def self.split_cigars(c)
    c.split(",").map{|str|str.cigar_operations}
  end

  def self.split_segment_names(sn)
    retval = []
    sn.split(",").each do |elem|
      elem =~ /(.*)([\+-])/
      raise TypeError if $1.nil? # this should be impossible
      retval << [$1, $2]
    end
    return retval
  end

end
