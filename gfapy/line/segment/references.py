import gfapy

class References:

  @property
  def dovetails(self):
    """
    References to the graph lines which involve the segment as dovetail overlap.

    Returns
    -------
    gfapy.line.Edge list
      A list of lines.
      The lines themselves can be modified, but the list is immutable.
    """
    return self.dovetails_L + self.dovetails_R

  def dovetails_of_end(self, extremity):
    """
    References to the graph lines which involve the segment as dovetail overlap.

    Returns
    -------
    gfapy.line.Edge list
      A list of lines.
      The lines themselves can be modified, but the list is immutable.
    """
    return getattr(self, "dovetails_{}".format(extremity))

  @property
  def gaps(self):
    """
    References to the gap lines which involve the segment.
    """
    return self.gaps_L + self.gaps_R

  def gaps_of_end(self, extremity):
    """
    References to the gap lines which involve the segment.
    """
    return getattr(self, "gaps_{}".format(extremity))

  @property
  def containments(self):
    """
    References to graph edges (C lines for GFA1, E for GFA2) which involve the
    segment in a containment relationship.
    """
    return self.edges_to_contained + self.edges_to_containers

  @property
  def connectivity(self):
    """
    Computes the connectivity of a segment from its number of dovetail overlaps.

    Returns
    -------
    (conn_symbol,conn_symbol) list

    conn. symbols respectively of the :L and :R ends of +segment+.

    <b>Connectivity symbol:</b> (+conn_symbol+)
    - Let _n_ be the number of links to an end (+:L+ or +:R+) of a segment.
    Then the connectivity symbol is +:M+ if <i>n > 1</i>, otherwise _n_.
    """
    if not self.is_connected():
      raise gfapy.ArgumentError(
        "Cannot compute the connectivity of {}\n".format(self)+
        "Segment is not connected to a GFA instance")
    return self.__connectivity_symbols(len(dovetails_L), len(dovetails_R))

  @property
  def neighbours(self):
    """
    List of dovetail-neighbours of a segment.

    Returns
    -------
    gfapy.line.Segment list
    	Segments connected to the current segment by dovetail overlap
      relationships (L lines for GFA1, dovetail-representing E lines for GFA2)
    """
    return list(set([ l.other(self) for l in self.dovetails ]))

  @property
  def neighbours_L(self):
    """
    List of dovetail-neighbours of a segment.

    Returns
    -------
    gfapy.line.Segment list
    	Segments connected to the current segment by dovetail overlap
      relationships (L lines for GFA1, dovetail-representing E lines for GFA2)
    """
    return list(set([ l.other(self) for l in self.dovetails_L ]))

  @property
  def neighbours_R(self):
    """
    List of dovetail-neighbours of a segment.

    Returns
    -------
    gfapy.line.Segment list
    	Segments connected to the current segment by dovetail overlap
      relationships (L lines for GFA1, dovetail-representing E lines for GFA2)
    """
    return list(set([ l.other(self) for l in self.dovetails_R ]))

  @property
  def containers(self):
    """
    List of segments which contain the segment.

    Returns
    -------
    gfapy.line.Segment list
    	Segments connected to the current segment by containment relationships
      (C lines for GFA1, containment-representing E lines for GFA2),
      where the current segment is the contained segment.
    """
    return list(set([ elem.frm for elem in self.edges_to_contained ]))

  @property
  def contained(self):
    """
    List of segments which are contained in the segment.

    Returns
    -------
    gfapy.line.Segment list
    	Segments connected to the current segment by containment relationships
      (C lines for GFA1, containment-representing E lines for GFA2),
      where the current segment is the container segment.
    """
    return list(set([ elem.to for elem in self.edges_to_contained ]))

  @property
  def edges(self):
    """
    List of edges which refer to the segment

    Returns
    -------
    gfapy.line.Edge list
    """
    return self.dovetails + self.containments + self.internals

  def relations_to(self, segment, collection="edges"):
    if isinstance(segment, gfapy.Line):
      return [e for e in getattr(self, collection) \
          if (e.other(self) is segment)]
    else:
      return [e for e in getattr(self, collection) \
          if (e.other(self).name == segment)]

  def oriented_relations(self, orientation, oriented_segment, collection="edges"):
    return [e for e in getattr(self, collection) if \
      (e.other_oriented_segment(gfapy.OrientedLine(self, orientation), tolerant=True) == \
        oriented_segment)]

  def end_relations(self, extremity, segment_end, collection ="edges"):
    return [e for e in getattr(self, collection) if \
      (e.other_end(gfapy.SegmentEnd(self, extremity), tolerant=True) == \
        segment_end)]

  def _connectivity_symbols(self, n, m):
    return [self.__connectivity_symbol(n), self.__connectivity_symbol(m)]

  def _connectivity_symbol(self, n):
    return "M" if n > 1 else n

  def _backreference_keys(self, ref, key_in_ref):
    if ref.record_type == "E":
      return ["dovetails_L", "dovetails_R", "internals",
              "edges_to_containers", "edges_to_contained"]
    elif ref.record_type == "L":
      return ["dovetails_L", "dovetails_R"]
    elif ref.record_type == "C":
      return ["edges_to_contained"] if (key_in_ref == "from") \
        else ["edges_to_containers"]
    elif ref.record_type == "G":
      return ["gaps_L", "gaps_R"]
    elif ref.record_type == "F":
      return ["fragments"]
    elif ref.record_type == "P" or ref.record_type == "O":
      return ["paths"]
    elif ref.record_type == "U":
      return ["sets"]
    else:
      return []
