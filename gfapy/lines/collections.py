import gfapy

class Collections:
  @property
  def comments(self):
    return self._records["#"]

  @property
  def gfa1_containments(self):
    return self._records["C"]

  @property
  def gfa1_links(self):
    return self._records["L"]

  @property
  def gfa2_edges(self):
    d = self._records["E"]
    return [v for k,v in d.items() if k is not None] + d[None]

  @property
  def gaps(self):
    d = self._records["G"]
    return [v for k,v in d.items() if k is not None] + d[None]

  @property
  def sets(self):
    d = self._records["U"]
    return [v for k,v in d.items() if k is not None] + d[None]

  @property
  def gfa2_paths(self):
    d = self._records["O"]
    return [v for k,v in d.items() if k is not None] + d[None]

  @property
  def gfa2_edge_names(self):
    d = self._records["E"]
    return [k for k in d.keys() if k is not None]

  @property
  def gap_names(self):
    d = self._records["G"]
    return [k for k in d.keys() if k is not None]

  @property
  def set_names(self):
    d = self._records["U"]
    return [k for k in d.keys() if k is not None]

  @property
  def gfa2_path_names(self):
    d = self._records["O"]
    return [k for k in d.keys() if k is not None]

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
    return [f for e in d.values() for f in e]

  @property
  def external_names(self):
    return list(self._records["F"].keys())

  @property
  def names(self):
    return self.segment_names + \
      self.edge_names + \
      self.gap_names + \
      self.path_names + \
      self.set_names

  GFA1_ONLY_KEYS = ["L", "C", "P"]

  NONCUSTOM_GFA2_KEYS = ["H", "#", "F", "S", "E", "G", "U", "O", None]

  @property
  def custom_record_keys(self):
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
    cr = []
    for k in self.custom_record_keys:
      collection = self._records[k]
      if isinstance(collection,dict):
        cr += list(collection.values())
      else:
        cr += collection
    return cr

  def custom_records_of_type(self, record_type):
    if record_type not in self.custom_record_keys:
      return []
    try:
      collection = self._records[record_type]
    except NameError:
      return []
    else:
      if isinstance(collection,dict):
        return list(collection.values())
      else:
        return collection

  @property
  def lines(self):
    return self.comments + \
      self.headers + \
      self.segments + \
      self.edges + \
      self.paths + \
      self.sets + \
      self.gaps + \
      self.fragments + \
      self.custom_records
