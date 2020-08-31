import gfapy

class RedundantLinearPaths:

  def _junction_junction_paths(self, sn, exclude):
    retval = []
    exclude.add(sn)
    s = self.segment(sn)
    for dL in s.dovetails_L:
      eL = dL.other_end(gfapy.SegmentEnd(s, "L"))
      if (eL.name in exclude) or (len(eL.segment.dovetails_of_end(eL.end_type)) == 1):
        retval.append([True, eL, gfapy.SegmentEnd(s, "R"), True])
    for dR in s.dovetails_R:
      eR = dR.other_end(gfapy.SegmentEnd(s, "R"))
      if (eR.name in exclude) or (len(eR.segment.dovetails_of_end(eR.end_type)) == 1):
        retval.append([True, gfapy.SegmentEnd(s, "R"), eR.inverted(), True])
    return retval

  def _extend_linear_path_to_junctions(self, segpath):
    segfirst = self.segment(segpath[0].segment)
    segfirst_d = segfirst.dovetails_of_end(gfapy.invert(segpath[0].end_type))
    redundant_first = (len(segfirst_d) > 0)
    if len(segfirst_d) == 1:
      segpath.insert(0, segfirst_d[0].other_end(segpath[0].inverted()))
    segpath.insert(0, redundant_first)
    seglast = self.segment(segpath[-1].segment)
    seglast_d = seglast.dovetails_of_end(segpath[-1].end_type)
    redundant_last = (len(seglast_d) > 0)
    if len(seglast_d) == 1:
      segpath.append(seglast_d[0].other_end(segpath[-1].inverted()))
    segpath.append(redundant_last)

  def _link_duplicated_first(self, merged, first, is_reversed, jntag):
    # annotate junction
    if jntag is None:
      jntag = "jn"
    if not first.get(jntag):
      first.set(jntag, {"L":[],"R":[]})
    if is_reversed:
      first.get(jntag)["L"].append([merged.name, "-"])
    else:
      first.get(jntag)["R"].append([merged.name, "+"])
    # create temporary link
    ln = len(first.sequence)
    if self._version == "gfa1":
      tmp_link = gfapy.line.edge.Link([first.name, \
        "-" if is_reversed else "+", merged.name, "+", \
        "{}M".format(ln), "co:Z:temporary"])
      self.add_line(tmp_link)
    elif self._version == "gfa2":
      tmp_link = gfapy.line.edge.GFA2(["*",first.name + \
        ("-" if is_reversed else "+"), merged.name+"+",
        "0" if is_reversed else str(ln-1), # on purpose fake
        "1" if is_reversed else "{}$".format(ln), # on purpose fake
        0, str(ln), "{}M".format(ln), "co:Z:temporary"])
      self.add_line(tmp_link)
    else:
      raise gfapy.AssertionError()

  def _link_duplicated_last(self, merged, last, is_reversed, jntag):
    # annotate junction
    if jntag is None:
      jntag = "jn"
    if not last.get(jntag):
      last.set(jntag, {"L":[],"R":[]})
    if is_reversed:
      last.get(jntag)["R"].append([merged.name, "-"])
    else:
      last.get(jntag)["L"].append([merged.name, "+"])
    # create temporary link
    ln = len(last.sequence)
    if self._version == "gfa1":
      tmp_link = gfapy.line.edge.Link([merged.name, "+",
          last.name, "-" if is_reversed else "+",
          "{}M".format(ln), "co:Z:temporary"])
      self.add_line(tmp_link)
    elif self._version == "gfa2":
      mln = len(merged.sequence)
      tmp_link = gfapy.line.edge.GFA2(["*",merged.name+"+", \
        last.name+("-" if is_reversed else "+"),
        str(mln - ln), "{}$".format(mln),
        str(ln-1) if is_reversed else "0", # on purpose fake
        "{}$".format(ln) if is_reversed else "1", # on purpose fake
        "{}M".format(ln), "co:Z:temporary"])
      self.add_line(tmp_link)
    else:
      raise gfapy.AssertionError()

  def _remove_junctions(self, jntag):
    if jntag is None:
      jntag = "jn"
    for s in self.segments:
      jndata = s.get(jntag)
      if jndata:
        ln = len(s.sequence)
        for m1, dir1 in jndata["L"].items():
          for m2, dir2 in jndata["R"].items():
            if self._version == "gfa1":
              l = gfapy.line.edge.Link([m1,dir1,m2,dir2,"{}M".format(ln)])
              self.add_line(l)
            elif self._version == "gfa2":
              m1ln = len(self.segment(m1).sequence)
              m2ln = len(self.segment(m2).sequence)
              r1 = (dir1 == "-")
              r2 = (dir2 == "-")
              l = gfapy.line.edge.GFA2(["*", m1+dir1, m2+dir2,
                 "0" if r1 else str(m1ln-ln),
                 str(ln) if r1 else str(m1ln)+"$",
                 "0" if r2 else str(m2ln-ln),
                 str(ln) if r1 else str(m2ln)+"$",
                 str(ln)+"M"])
              self.add_line(l)
            else:
              raise gfapy.AssertionError()
        s.disconnect()

