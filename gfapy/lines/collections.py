import gfapy

class Collections:
  @property
  def comments(self):
    d = self._records["#"]
    return list(d.values())

  @property
  def gfa1_containments(self):
    d = self._records["C"]
    return list(d.values())

  @property
  def gfa1_links(self):
    d = self._records["L"]
    return list(d.values())

  @property
  def gfa2_edges(self):
    d = self._records["E"]
    return list(d.values())

  @property
  def gaps(self):
    d = self._records["G"]
    return list(d.values())

  @property
  def sets(self):
    d = self._records["U"]
    return list(d.values())

  @property
  def gfa2_paths(self):
    d = self._records["O"]
    return list(d.values())

  @property
  def gfa2_edge_names(self):
    d = self._records["E"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def gap_names(self):
    d = self._records["G"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def set_names(self):
    d = self._records["U"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def gfa2_path_names(self):
    d = self._records["O"]
    return list([k for k in d.keys() if isinstance(k, str)])

  @property
  def segments(self):
    d = self._records["S"]
    return list(d.values())

  @property
  def gfa1_paths(self):
    d = self._records["P"]
    return list(d.values())

  @property
  def segment_names(self):
    d = self._records["S"]
    return list(d.keys())

  @property
  def gfa1_path_names(self):
    d = self._records["P"]
    return list(d.keys())

  @property
  def edges(self):
    if self._version == "gfa1":
      return self.gfa1_links + self.gfa1_containments
    elif self._version == "gfa2":
      return self.gfa2_edges
    else:
      return self.gfa1_links + self.gfa1_containments + self.gfa2_edges

  @property
  def dovetails(self):
    if self._version == "gfa1":
      return self.gfa1_links
    elif self._version == "gfa2":
      return [ e for e in self.gfa2_edges if e.is_dovetail() ]
    else:
      return self.gfa1_links + \
        [ e for e in self.gfa2_edges if e.is_dovetail() ]

  @property
  def containments(self):
    if self._version == "gfa1":
      return self.gfa1_containments
    elif self._version == "gfa2":
      return [ e for e in self.gfa2_edges if e.is_containment() ]
    else:
      return self.gfa1_containments + \
        [ e for e in self.gfa2_edges if e.is_containment() ]

  @property
  def edge_names(self):
    return self.gfa2_edge_names

  @property
  def paths(self):
    return self.gfa1_paths + self.gfa2_paths

  @property
  def path_names(self):
    return self.gfa1_path_names + self.gfa2_path_names

  @property
  def fragments(self):
    d = self._records["F"]
    return [f for e in d.values() for f in e.values()]

  @property
  def external_names(self):
    """Identifiers of the external sequences mentioned in F records"""
    return list(self._records["F"].keys())

  @property
  def names(self):
    """All identifiers in the GFA identifiers namespace"""
    return self.segment_names + \
      self.edge_names + \
      self.gap_names + \
      self.path_names + \
      self.set_names

  GFA1_ONLY_KEYS = ["L", "C", "P"]

  NONCUSTOM_GFA2_KEYS = ["H", "#", "F", "S", "E", "G", "U", "O", None]

  @property
  def custom_record_keys(self):
    """Record types of the custom records"""
    if self._version == "gfa1":
      return []
    else:
      keys = [k for k,v in self._records.items() if v]
      if self._version == "gfa2":
        return [k for k in keys if k not in self.NONCUSTOM_GFA2_KEYS]
      else:
        return [k for k in keys \
          if k not in self.NONCUSTOM_GFA2_KEYS and k not in self.GFA1_ONLY_KEYS]

  @property
  def custom_records(self):
    """All custom records"""
    cr = []
    for k in self.custom_record_keys:
      collection = self._records[k]
      cr += list(collection.values())
    return cr

  def custom_records_of_type(self, record_type):
    """List of custom records of the specified type"""
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
