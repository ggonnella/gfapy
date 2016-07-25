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

  def circular?
    self.cigars.size == self.segment_names.size
  end

  private

  def validate_lists_size!
    n_cigars = self.cigars.size
    n_segments = self.segment_names.size
    if n_cigars == n_segments - 1
      # case 1: linear path
      return true
    elsif n_cigars == 1 and self.cigars[0].empty?
      # case 2: linear path, single "*" to represent cigars which are all "*"
      return true
    elsif n_cigars == n_segments
      # case 3: circular path
    else
      raise RGFA::Line::Path::ListLengthsError,
        "Path has #{n_segments} oriented segments, "+
        "but #{n_cigars} CIGARs"
    end
  end

  def validate_record_type_specific_info!
    validate_lists_size!
  end


end

# Error raised if number of segments and cigars are not consistent
class RGFA::Line::Path::ListLengthsError < RGFA::Error; end
