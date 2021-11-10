import gfapy

class References:

  def _compute_required_links(self):
    """
    Computes the list of links which are required to support
    the path.

    Returns
    -------
    list of (gfapy.OrientedLine, gfapy.OrientedLine, gfapy.CIGAR)
      An array, which elements are 3-tuples
      (from oriented segment, to oriented segment, cigar)
    """
    if len(self.segment_names) == 1:
      return []
    has_undef_overlaps = self._undef_overlaps()
    retval = []
    is_circular = self.is_circular()
    for i in range(len(self.segment_names)):
      j = i+1
      if j == len(self.segment_names):
        if is_circular:
          j = 0
        else:
          break
      if has_undef_overlaps:
        cigar = gfapy.AlignmentPlaceholder()
      else:
        cigar = self.overlaps[i]
      retval.append([self.segment_names[i], self.segment_names[j], cigar])
    return retval

  def _undef_overlaps(self):
    """
    Are the overlaps a single "*"? This is a compact representation of
    a linear path where all CIGARs are "*".

    Returns
    -------
    bool
    """
    return len(self.overlaps) == 1 and gfapy.is_placeholder(self.overlaps[0])

  def _initialize_references(self):
    self._initialize_links()
    self._initialize_segments()

  def _initialize_links(self):
    self._refs["links"] = []
    for from_segment, to_segment, cigar in self._compute_required_links():
      l = None
      orient = "+"
      if self._gfa.segment(from_segment.line) and self._gfa.segment(to_segment.line):
        l = self._gfa._search_link(from_segment, to_segment, cigar)
        if l is not None and l.is_compatible_complement(from_segment, to_segment, cigar):
          orient = "-"
      if l is None:
        if self._gfa._segments_first_order:
          raise gfapy.NotFoundError("Path: {}\n".format(self)+
          "requires a non-existing link:\n"+
          "from={} to={} cigar={}".format(from_segment, to_segment, cigar))
        l = gfapy.line.edge.Link({"from_segment" : from_segment.line,
                                  "from_orient" : from_segment.orient,
                                  "to_segment" : to_segment.line,
                                  "to_orient" : to_segment.orient,
                                  "overlap" : cigar},
                                 virtual = True,
                                 version = "gfa1")
        l.connect(self._gfa)
      self._refs["links"].append(gfapy.OrientedLine(l,orient))
      l._add_reference(self, "paths")

  def _initialize_segments(self):
    for sn_with_o in self.segment_names:
      s = self._gfa.segment(sn_with_o.line)
      sn_with_o.line = s
      s._add_reference(self, "paths")

  def _backreference_keys(self, ref, key_in_ref):
    if ref.record_type == "L":
      return ["links"]
    elif ref.record_type == "S":
      return ["segment_names"]
