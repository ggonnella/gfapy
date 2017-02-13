class References:

  def dovetails(self, extremity = None):
    """
    References to the graph lines which involve the segment as dovetail overlap.

    Parameters
    ----------
    extremity : "L" or "R" or None, optional
    	Left or right extremity of the segment.
      (default: both)

    Returns
    -------
    gfapy.line.Edge list
      A list of lines.
      The lines themselves can be modified, but the list is immutable.

    .. note::
      To add a dovetail overlap, create a L (GFA1) or E (GFA2) line and
      connect it to the graph.
      To remove a dovetail overlap, call gfapy.Line.disconnect
      on the corresponding L or E line
    """
    if extremity is not None:
      dovetails = getattr(self, "dovetails_{}".format(extremity))
      return dovetails()
    else:
      return self.dovetails_L + self.dovetails_R

  def gaps(self, extremity = None):
    """
    References to the graph lines which involve the segment as dovetail overlap.
    Parameters
    ----------
    extremity : "L" or "R" or None, optional
    	Left or right extremity of the segment.
      (default: both)
    """
    if extremity is not None:
      gaps = getattr(self, "gaps_{}".format(extremity))
      return gaps()
    else:
      return self.gaps_L + self.gaps_R

  @property
  def containments(self):
    """
    References to graph edges (C lines for GFA1, E for GFA2) which involve the
    segment in a containment relationship.
    """
    return self.edges_to_contained + self.edges_to_containers

  @property
  def connectivity(self):
    #TODO: improve docstring
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

  def neighbours(self, extremity = None):
    """
    List of dovetail-neighbours of a segment.

    Returns
    -------
    gfapy.line.Segment list
    	Segments connected to the current segment by dovetail overlap
      relationships (L lines for GFA1, dovetail-representing E lines for GFA2)
    """
    return list(set([ l.other(self) for l in self.dovetails(extremity) ]))

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
    return list(set([ elem.frm for elem in self.edges_to_contained() ]))

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
    return list(set([ elem.to for elem in self.edges_to_contained() ]))

  @property
  def edges(self):
    """
    List of edges which refer to the segment
    	
    Returns
    -------
    gfapy.line.Edge list
    """
    return self.dovetails() + self.containments() + self.internals()

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
