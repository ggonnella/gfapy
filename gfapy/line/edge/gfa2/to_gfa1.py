import gfapy

class ToGFA1:

  def _to_gfa1_a(self):
    """List of the field content of the line in GFA1.
    """
    at = self._alignment_type
    if at == "I":
      raise gfapy.RuntimeError(
        "Conversion of edge line from GFA2 to GFA1 failed\n"+
        "Edge represents an internal overlap:\n"+
        "Edge line: {}\n".format(str(self)))
    a = [ at ]
    if self._is_sid1_from():
      ol1 = self.get("sid1")
      ol2 = self.get("sid2")
    else:
      ol1 = self.get("sid2")
      ol2 = self.get("sid1")
    a.append(ol1.name)
    a.append(ol1.orient)
    a.append(ol2.name)
    a.append(ol2.orient)
    if self._alignment_type == "C":
      a.append(str(self.pos))
    try:
      self.overlap.validate(version = "gfa1")
    except:
      raise gfapy.RuntimeError(
        "Conversion of edge line from GFA2 to GFA1 failed\n"+
        "Overlap is invalid or not compatible with GFA1\n"+
        "Edge line: {}\n".format(str(self)))
    a.append(str(self.overlap))
    if not gfapy.is_placeholder(self.eid):
      a.append(gfapy.Field._to_gfa_tag(self.eid, "ID", datatype = "Z"))
    for fn in self.tagnames:
      a.append(self.field_to_s(fn, tag = True))
    return a

  @property
  def overlap(self):
    """Value of the GFA1 **overlap** field, if the edge is a link or containment.

    Returns:
      gfapy.Alignment.Placeholder or gfapy.Alignment.CIGAR

    Raises:
      gfapy.error.ValueError: If the edge is internal
    """
    self._check_not_internal("overlap")
    return self.alignment.complement() if self._is_sid1_from() else self.alignment

  @property
  def oriented_from(self):
    return self.sid1 if self._is_sid1_from() else self.sid2

  @property
  def oriented_to(self):
    return self.sid2 if self._is_sid1_from() else self.sid1

  @property
  def from_segment(self):
    """Value of the GFA1 **from_segment** field, if the edge is a link or containment.

    Returns:
      str or gfapy.line.segment.GFA2

    Raises:
      gfapy.error.ValueError: If the edge is internal.
    """
    return self.oriented_from.line

  @from_segment.setter
  def from_segment(self, value):
    """Set the field which will be returned by calling from_segment

    Parameters:
      value (str, gfapy.line.segment.GFA2)
    """
    self.oriented_from.line = value

  @property
  def from_orient(self):
    """Value of the GFA1 **from_orient** field.

    This method can only be applied if the edge is a link or containment.

    Returns:
      str: one of ["+", "-"]

    Raises:
      gfapy.error.ValueError: If the edge is internal.
    """
    return self.oriented_from.orient

  @from_orient.setter
  def from_orient(self, value):
    """Set the orientation of the field which will be returned by calling
    from_segment

    Parameters:
      value (str): one of ["+", "-"]
    """
    self.oriented_from.orient = value

  @property
  def to_segment(self):
    """Value of the GFA1 ``to_segment`` field.

    This method can only be applied if the edge is a link or containment.

    Returns:
      str or gfapy.line.segment.GFA2

    Raises:
      gfapy.error.ValueError: If the edge is internal.
    """
    return self.oriented_to.line

  @to_segment.setter
  def to_segment(self, value):
    """Set the field which will be returned by calling ``to_segment``.

    Parameters:
      value (str or gfapy.line.segment.GFA2)
    """
    self.oriented_to.line = value

  @property
  def to_orient(self):
    """Value of the GFA1 **to_orient** field.

    This method can only be applied if the edge is a link or containment.

    Returns:
      str : one of ["+", "-"]

    Raises:
      gfapy.error.ValueError: If the edge is internal.
    """
    return self.oriented_to.orient

  @to_orient.setter
  def to_orient(self, value):
    """Set the orientation of the field which will be returned by calling
    ``to_segment``.

    Parameters:
      value (str): one of ["+", "-"]
    """
    self.oriented_to.orient = value

  @property
  def pos(self):
    """Value of the GFA1 **pos** field, if the edge is a containment.

    Returns:
      int or gfapy.Lastpos

    Raises:
      gfapy.error.ValueError: If the edge is not a containment.
    """
    if self._alignment_type == "I":
      raise gfapy.ValueError("Line: {}\n".format(str(self)) +
                             "Internal alignment, pos is not defined")
    elif self._alignment_type == "L":
      raise gfapy.ValueError("Line: {}\n".format(str(self)) +
                             "Dovetail alignment, pos is not defined")
    elif self._alignment_type == "C":
      if gfapy.isfirstpos(self.beg1):
        return self.beg1 if (gfapy.isfirstpos(self.beg2) and
                             gfapy.islastpos(self.end2)) else self.beg2
      else:
        return self.beg1

  def _check_not_internal(self, fn):
    if self.is_internal():
      raise gfapy.ValueError(
        "Line: {}\n".format(str(self))+
        "Internal alignment, {} is not defined".format(fn))

  @staticmethod
  def _segment_role(begpos, endpos, orient):
    if gfapy.isfirstpos(begpos):
      if gfapy.islastpos(endpos):
        return "contained"
      elif orient == "+":
        return "pfx"
      else:
        return "sfx"
    else:
      if gfapy.islastpos(endpos):
        if orient == "+":
          return "sfx"
        else:
          return "pfx"
      else:
        return "other"

  def _check_GFA1_overlap_compatibility(self):
    pass

  def _is_sid1_from(self):
    sr1 = self._segment_role(self.beg1, self.end1, self.sid1.orient)
    sr2 = self._segment_role(self.beg2, self.end2, self.sid2.orient)
    if sr2 == "contained":
      return True
    elif sr1 == "contained":
      return False
    elif sr1 == "sfx" and sr2 == "pfx":
      return True
    elif sr2 == "sfx" and sr1 == "pfx":
      return False
    else:
      raise gfapy.ValueError(
        "Line: {}\n".format(str(self))+
        "Internal overlap, 'from' is undefined\n"+
        "Roles: segment1 is {} ({},{}), segment2 is {} ({},{})".format(sr1,
          self.beg1, self.end1, sr2, self.beg2, self.end2))

