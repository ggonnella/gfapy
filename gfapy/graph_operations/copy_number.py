class CopyNumber:

  def set_default_count_tag(self, tag):
    """Set the count tag to be used by default for the coverage computation"""
    self._default["count_tag"] = tag

  def set_count_unit_length(self, unit_length):
    """Set the unit length to be used by default for the coverage computation"""
    self._default["unit_length"] = unit_length

  def delete_low_coverage_segments(self, mincov, count_tag=None,
                                   unit_length=None):
    """Remove the segments whose coverage is smaller than a specified value.

    Parameters:
      mincov (int) : the minimal coverage to keep a segment
      count_tag (str) : the name of the tag to use for coverage computation
      unit_length (int) : the unit length to use for coverage computation
    """
    if unit_length is None:
      unit_length = self._default["unit_length"]
    if count_tag is None:
      count_tag = self._default["count_tag"]
    for s in self.segments:
      cov = s.coverage(count_tag=count_tag, unit_length=unit_length)
      if cov < mincov:
        s.disconnect()

  def compute_copy_numbers(self, single_copy_coverage, mincov=None,
                           count_tag=None, cn_tag="cn", unit_length=None):
    """Compute the estimated copy numbers of all segments, from their coverage.

    Parameters:
      mincov (int) : the minimal coverage to assign copy number 1; if not
        specified, 1/4 of the single_copy_coverage is used
      single_copy_coverage : the coverage corresponding to a copy number of 1
      cn_tag (str) : the tag where to store the computed values (default: cn)
      count_tag (str) : the name of the tag to use for coverage computation
      unit_length (int) : the unit length to use for coverage computation
    """
    if mincov is None:
      mincov = single_copy_coverage * 0.25
    if count_tag is None:
      count_tag = self._default["count_tag"]
    if unit_length is None:
      unit_length = self._default["unit_length"]
    for s in self.segments:
      cov = s.try_get_coverage(count_tag=count_tag, unit_length=unit_length)
      if cov < mincov:
        cn = 0
      elif cov < single_copy_coverage:
        cn = 1
      else:
        cn = round(cov / single_copy_coverage)
      s.set(cn_tag, cn)

  def apply_copy_numbers(self, count_tag="cn", distribute="auto",
                         origin_tag="or", conserve_components=True):
    """Multiply each segment per its copy number.

    The copy number must be stored in a tag (default: cn). It can be computed
    e.g. using the compute_copy_numbers() method.

    Parameters:
      origin_tag (str) : the tag where to store the origin tracking
        (default: or); see multiply()
      distribute (str) : the value of the distribute parameter of multiply();
        see multiply()
      count_tag (str) : the name of the tag to use for coverage computation
      conserve_components (bool) : If True, segments with copy number 0 are
        not deleted, if their removal would split a connected component in two;
        thereby only dovetail overlaps are considered (default: False)
    """
    for s in sorted(self.segments, key=lambda s:s.try_get(count_tag)):
      self.multiply(s.name, s.get(count_tag), distribute=distribute,
               copy_names=None, conserve_components=conserve_components,
               origin_tag=origin_tag, track_origin=True)
