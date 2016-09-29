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
      cigar = gfapy.AlignmentPlaceholder if has_undef_overlaps else self.overlaps[i]
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
    self.overlaps.size == 1 and not self.overlaps[0]

  def _initialize_references(self):
    self._initialize_links()
    self._initialize_segments()

  def _initialize_links(self):
    self.refs["links"] = []
    for frm, to, cigar in self._compute_required_links():
      l = None
      orient = "+"
      if self.gfa.segment(frm.line) and self.gfa.segment(to.line):
        l = self.gfa.search_link(frm, to, cigar)
        if l is not None and l.compatible_complement(frm, to, cigar):
          orient = "-"
      if l is None:
        if self.gfa.segments_first_order:
          raise gfapy.NotFoundError("Path: {}\n".format(self)+
          "requires a non-existing link:\n"+
          "from={} to={} cigar={}".format(frm, to, cigar))
        l = gfapy.line.edge.Link({"from" : frm.line,
                                  "from_orient" : frm.orient,
                                  "to" : to.line,
                                  "to_orient" : to.orient,
                                  "overlap" : cigar},
                                 virtual = True,
                                 version = "gfa1")
        l.connect(self.gfa)
      self.refs["links"].append(gfapy.OrientedLine(l,orient))
      l.add_reference(self, "paths")

  def _initialize_segments(self):
    for sn_with_o in self.segment_names:
      s = self.gfa.segment(sn_with_o.line)
      sn_with_o.line = s
      s.add_reference(self, "paths")

  def _backreference_keys(self, ref, key_in_ref):
    if ref.record_type == "L":
      return ["links"]
    elif ref.record_type == "S":
      return ["segment_names"]
