module RGFA::Line::Group::Path::Topology

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

end
