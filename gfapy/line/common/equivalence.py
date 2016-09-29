class Equivalence:

  def __eq__(self, o):
    """
    Equivalence check
    
    Returns
    -------
    bool
      does the line has the same record type,
      contains the same tags
      and all positional fields and tags contain the same field values?

    See Also
    --------
    gfapy.Line.Edge.Link.__eq__
    """
    if isinstance(o, str): return str(self) == str(o)
    if (o.record_type != self.record_type): return False
    if sorted(o.data.keys()) != sorted(self.data.keys()): return False
    for k,v in o.data.items():
      if self.data[k] != v:
        if self.field_to_s(k) != o.field_to_s(k):
          return False
    return True

  @property
  def _data(self):
    return self.data

  @property
  def _datatype(self):
    return self.datatype
