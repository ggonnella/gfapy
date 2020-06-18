class Collections:
  @property
  def comments(self):
    """List of the comment lines (lines starting with #).

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    d = self._records["#"]
    return list(d.values())

  @property
  def gaps(self):
    """List of the gap (G) lines. The list is empty in GFA1.

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    d = self._records["G"]
    return list(d.values())

  @property
  def sets(self):
    """List of the set (U) lines. The list is empty in GFA1.

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    d = self._records["U"]
    return list(d.values())

  @property
  def segments(self):
    """List of the segment (S) lines.

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    d = self._records["S"]
    return list(d.values())

  @property
  def edges(self):
    """List of the edge lines.

    Edge lines are L and C lines in GFA1 and E lines in GFA2.

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    if self._version == "gfa1":
      return self._gfa1_links + self._gfa1_containments
    elif self._version == "gfa2":
      return self._gfa2_edges
    else:
      return self._gfa1_links + self._gfa1_containments + self._gfa2_edges

  @property
  def dovetails(self):
    """List of the dovetail edge lines.

    Dovetail edge lines are L lines in GFA1 and E lines representing dovetail
    overlaps in GFA2.

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    if self._version == "gfa1":
      return self._gfa1_links
    elif self._version == "gfa2":
      return [ e for e in self._gfa2_edges if e.is_dovetail() ]
    else:
      return self._gfa1_links + \
        [ e for e in self._gfa2_edges if e.is_dovetail() ]

  @property
  def containments(self):
    """List of the containment edge lines.

    Containment edge lines are C lines in GFA1 and E lines representing
    containments in GFA2.

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    if self._version == "gfa1":
      return self._gfa1_containments
    elif self._version == "gfa2":
      return [ e for e in self._gfa2_edges if e.is_containment() ]
    else:
      return self._gfa1_containments + \
        [ e for e in self._gfa2_edges if e.is_containment() ]

  @property
  def paths(self):
    """List of the path lines (P in GFA1, O in GFA2).

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    return self._gfa1_paths + self._gfa2_paths

  @property
  def fragments(self):
    """List of the fragment (F) lines. The list is empty in GFA1.

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    d = self._records["F"]
    return [f for e in d.values() for f in e.values()]

  @property
  def custom_records(self):
    """List of the custom records of the GFA. The list is empty for GFA1.

    All records with a non-standard first field (record type) are considered
    custom records.

    Note:
      adding or removing elements to the list, does not add or removes
      lines from the Gfa instance. For this, the add_line() and rm() methods
      shall be used. Calling disconnect() on a line of the list, however,
      removes the line from the instance.
    """
    cr = []
    for k in self.custom_record_keys:
      collection = self._records[k]
      cr += list(collection.values())
    return cr

  @property
  def _gfa1_containments(self):
    d = self._records["C"]
    return list(d.values())

  @property
  def _gfa1_links(self):
    d = self._records["L"]
    return list(d.values())

  @property
  def _gfa2_edges(self):
    d = self._records["E"]
    return list(d.values())

  @property
  def _gfa2_paths(self):
    d = self._records["O"]
    return list(d.values())

  @property
  def gap_names(self):
    """List of the names of the gap (G) lines. The list is empty in GFA1.
    """
    d = self._records["G"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def set_names(self):
    """List of the names of the set (U) lines. The list is empty in GFA1.
    """
    d = self._records["U"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def segment_names(self):
    """List of the names of the segment (S) lines.
    """
    d = self._records["S"]
    return list(d.keys())

  @property
  def edge_names(self):
    """List of the names of the edge (E, L, C) lines.

    For the L and C lines, the content of the custom tag id
    is taken as name.
    """
    if self._version == "gfa1":
      return self._link_names + self._containment_names
    elif self._version == "gfa2":
      return self._gfa2_edge_names
    else:
      return self._gfa2_edge_names + self._link_names + self._containment_names

  @property
  def path_names(self):
    """List of the names of the path lines (P for GFA1, O for GFA2).
    """
    return self._gfa1_path_names + self._gfa2_path_names

  @property
  def names(self):
    """All identifiers in the GFA identifiers namespace.

    Notes:
      GFA1: in Gfapy the P and S namespaces are joined (i.e. paths with
      the same name as segments are not accepted). Furthermore, to simplify
      the conversion to/from GFA2, the ID tag is used in L and C lines,
      and their content is also included in the same namespace as the S/P
      identifiers. GFA2: the namespace for identifiers is described in
      the specification and includes all the S, E, G, U and O lines; the
      external sequence identifiers in F lines are not included.
    """
    return self.segment_names + \
      self.edge_names + \
      self.gap_names + \
      self.path_names + \
      self.set_names

  def unused_name(self):
    """Compute a GFA identifier not yet in use in the Gfa object."""
    self._max_int_name += 1
    return str(self._max_int_name)

  @property
  def external_names(self):
    """List of the identifiers of external sequences mentioned in F records.
    The list is empty in GFA1.
    """
    return list(self._records["F"].keys())

  @property
  def _gfa2_edge_names(self):
    d = self._records["E"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def _link_names(self):
    d = self._records["L"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def _containment_names(self):
    d = self._records["C"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def _gfa2_path_names(self):
    d = self._records["O"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def _gfa1_paths(self):
    d = self._records["P"]
    return list(d.values())

  @property
  def _gfa1_path_names(self):
    d = self._records["P"]
    return list(d.keys())

  GFA1_ONLY_KEYS = ["L", "C", "P"]

  NONCUSTOM_GFA2_KEYS = ["H", "#", "F", "S", "E", "G", "U", "O", "\t"]

  @property
  def custom_record_keys(self):
    """Record types of the custom records.

    Returns:
      list of str
    """
    if self._version == "gfa1":
      return []
    else:
      keys = [k for k,v in self._records.items() if v]
      if self._version == "gfa2":
        return [k for k in keys if k not in self.NONCUSTOM_GFA2_KEYS]
      else:
        return [k for k in keys \
          if k not in self.NONCUSTOM_GFA2_KEYS and k not in self.GFA1_ONLY_KEYS]

  def custom_records_of_type(self, record_type):
    """List of custom records of the specified type."""
    if record_type not in self.custom_record_keys:
      return []
    return list(self._records[record_type].values())

  @property
  def lines(self):
    """All the lines of the GFA"""
    return self.comments + \
      self.headers + \
      self.segments + \
      self.edges + \
      self.paths + \
      self.sets + \
      self.gaps + \
      self.fragments + \
      self.custom_records
