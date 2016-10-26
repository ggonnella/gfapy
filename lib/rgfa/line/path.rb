# A path line of a RGFA file
class RGFA::Line::Path < RGFA::Line

  RECORD_TYPE = :P
  POSFIELDS = {:"1.0" => [:path_name, :segment_names, :overlaps],
               :"2.0" => nil}
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {}
  DATATYPE = {
    :path_name => :lbl,
    :segment_names => :lbs,
    :overlaps => :cgs,
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

  # Is the path circular? In this case the number of CIGARs must be
  # equal to the number of segments.
  # @return [Boolean]
  def circular?
    self.overlaps.size == self.segment_names.size
  end

  # Is the path linear? This is the case when the number of CIGARs
  # is equal to the number of segments minus 1, or the CIGARs are
  # represented by a single "*".
  def linear?
    !circular?
  end

  # Are the overlaps a single "*"? This is a compact representation of
  # a linear path where all CIGARs are "*"
  # @return [Boolean]
  def undef_overlaps?
    self.overlaps.size == 1 and self.overlaps[0].empty?
  end

  # The links to which the path refers; it can be an empty array
  # (e.g. from a line which is not embedded in a graph);
  # the boolean is true if the equivalent reverse link is used.
  # @return [Array<RGFA::Line::Link, Boolean>]
  def links
    @links ||= []
    @links
  end

  # computes the list of links which are required to support
  # the path
  # @return [Array<[RGFA::OrientedSegment, RGFA::OrientedSegment, RGFA::CIGAR]>]
  #   an array, which elements are 3-tuples (from oriented segment,
  #   to oriented segment, cigar)
  def required_links
    has_undef_overlaps = self.undef_overlaps?
    retval = []
    self.segment_names.size.times do |i|
      j = i+1
      if j == self.segment_names.size
        circular? ? j = 0 : break
      end
      cigar = has_undef_overlaps ? RGFA::Placeholder.new : self.overlaps[i]
      retval << [self.segment_names[i], self.segment_names[j], cigar]
    end
    retval
  end

  private

  def validate_lists_size!
    n_overlaps = self.overlaps.size
    n_segments = self.segment_names.size
    if n_overlaps == n_segments - 1
      # case 1: linear path
      return true
    elsif n_overlaps == 1 and self.overlaps[0].empty?
      # case 2: linear path, single "*" to represent overlaps which are all "*"
      return true
    elsif n_overlaps == n_segments
      # case 3: circular path
    else
      raise RGFA::InconsistencyError,
        "Path has #{n_segments} oriented segments, "+
        "but #{n_overlaps} overlaps"
    end
  end

  def validate_record_type_specific_info!
    validate_lists_size!
  end


end
