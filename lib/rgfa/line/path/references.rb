module RGFA::Line::Path::References

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
  # @api private
  def required_links
    has_undef_overlaps = undef_overlaps?
    retval = []
    segment_names.size.times do |i|
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

  # Are the overlaps a single "*"? This is a compact representation of
  # a linear path where all CIGARs are "*"
  # @return [Boolean]
  # @api private
  def undef_overlaps?
    overlaps.size == 1 and overlaps[0].empty?
  end

end
