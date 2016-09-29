import gfapy

class ToGFA1:

  def to_gfa1_a(self):
    """
    Returns
    -------
    list of str
      An list of fields of the equivalent line
      in GFA1, if the edge is a link or containment.

    Raises
    ------
    gfapy.ValueError
      If the edge is internal.
    """
    self._check_not_internal("GFA1 representation")
    a = [ self.alignment_type ]
    a.append(self.oriented_from.name)
    a.append(self.oriented_from.orient)
    a.append(self.oriented_to.name)
    a.append(self.oriented_to.orient)
    if self.alignment_type == "C":
      a.append(str(self.pos))
    s = str(self.overlap)
    a.append(s)
    if not self.eid.is_placeholder():
      a.append(self.eid.to_gfa_field(datatype = "Z", fieldname = "ID"))
    for fn in self.tagnames:
      a.append(self.field_to_s(fn, tag = True))
    return a

  @property
  def overlap(self):
    """
    Returns
    -------
    gfapy.Alignment.Placeholder or gfapy.Alignment.CIGAR
      Value of the GFA1 **overlap** field, if the edge is a link or containment.

    Raises
    ------
    gfapy.ValueError
      If the edge is internal.
    """
    self._check_not_internal("overlap")
    return self.alignment.complement() if gfapy.LastPos.get_is_first(self.beg1) else self.alignment

  @property
  def oriented_from(self):
    if gfapy.LastPos.get_is_first(self.beg1):
      return tself.sid1 if (gfapy.LastPos.get_is_first(self.beg2) and gfapy.LastPos.get_is_last(self.end2)) else self.sid2
    else:
      return self.sid1

  @property
  def oriented_to(self):
    if gfapy.LastPos.get_is_first(self.beg1):
      return self.sid2 if (gfapy.LastPos.get_is_first(self.beg2) and gfapy.LastPos.get_is_last(self.end2)) else self.sid1
    else:
      return self.sid2

  @property
  def frm(self):
    """
    Returns
    -------
    str, gfapy.Line.Segment.GFA2
      Value of the GFA1 **from** field, if the edge is a link or containment.

    Raises
    ------
    gfapy.ValueError
      If the edge is internal.
    """
    self._check_not_internal("from")
    return self.oriented_from.line

  @frm.setter
  def frm(self, value):
    """
    Set the field which will be returned by calling from

    Parameters
    ----------
    str, gfapy.Line.Segment.GFA2
    """
    self._check_not_internal("from")
    self.oriented_from.line = value

  @property
  def from_orient(self):
    """
    Returns
    -------
    one of ["+", "-"]
      Value of the GFA1 **from_orient** field,
      if the edge is a link or containment.

    Raises
    ------
    gfapy.ValueError
      If the edge is internal.
    """
    self._check_not_internal("from_orient")
    return self.oriented_from.orient

  @property
  def to(self):
    """
    Returns
    -------
    str, gfapy.Line.Segment.GFA2
      Value of the GFA1 **to** field, if the edge is a link or containment.

    Raises
    ------
    gfapy.ValueError
      If the edge is internal.
    """
    self._check_not_internal("to")
    return self.oriented_to.line

  @to.setter
  def to(self, value):
    """
    Set the field which will be returned by calling to.

    Parameters
    ----------
    value : str, gfapy.Line.Segment.GFA2
    """
    self._check_not_internal("to")
    self.oriented_to.line = value

  @property
  def to_orient(self):
    """
    Returns
    -------
    one of ["+", "-"]
      Value of the GFA1 **to_orient** field, if the edge is a link or containment.

    Raises
    ------
    gfapy.ValueError
      If the edge is internal.
    """
    self._check_not_internal("to_orient")
    return self.oriented_to.orient

  @property
  def pos(self):
    """
    Returns
    -------
    gfapy.Integer
      Value of the GFA1 **pos** field, if the edge is a containment.

    Raises
    ------
    gfapy.ValueError
      If the edge is not a containment.
    """
    if self.alignment_type == "I":
      raise gfapy.ValueError("Line: {}\n".format(str(self)) +
                             "Internal alignment, pos is not defined")
    elif self.alignment_type == "L":
      raise gfapy.ValueError("Line: {}\n".format(str(self)) +
                             "Dovetail alignment, pos is not defined")
    elif self.alignment_type == "C":
      if gfapy.LastPos.get_is_first(self.beg1):
        return self.beg1 if (gfapy.LastPos.get_is_first(self.beg2) and
                             gfapy.LastPos.get_is_last(self.end2)) else self.beg2
      else:
        return self.beg1

  def _check_not_internal(self, fn):
    if self.is_internal():
      raise gfapy.ValueError(
        "Line: {}\n".format(str(self))+
        "Internal alignment, {} is not defined".format(fn))
