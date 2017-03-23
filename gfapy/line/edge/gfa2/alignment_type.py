import gfapy

class AlignmentType:

  @property
  def _alignment_type(self):
    """The alignment type (C, L or I).

    Returns:
      C, L or I: C if containment, L if link, I (internal) otherwise.
    """
    st1 = self._substring_type(self.beg1, self.end1)[0]
    st2 = self._substring_type(self.beg2, self.end2)[0]
    return self._alignment_type_for_substring_types(st1, st2)

  def _alignment_type_for_substring_types(self, st1, st2):
    if st1 == "whole" or st2 == "whole":
      return "C"
    elif self.sid1.orient == self.sid2.orient:
      if (st1 == "pfx" and st2 == "sfx") or (st1 == "sfx" and st2 == "pfx"):
        return "L"
      else:
        return "I"
    else:
      if (st1 == "pfx" and st2 == "pfx") or (st1 == "sfx" and st2 == "sfx"):
        return "L"
      else:
        return "I"

  def _substring_type(self, begpos, endpos):
    """Type of substring (pfx, sfx, whole, internal) given start and end pos.

    Analyzes the begin and end position and determine if the substring is
    the whole string, or a (possibly empty) other substring, ie a prefix,
    a suffix, or an internal alignment.
    """
    if gfapy.posvalue(begpos) > gfapy.posvalue(endpos):
      raise gfapy.ValueError(
        "Line: {}\n".format(str(self))+
        "begin > end: {}$ > {}".format(gfapy.posvalue(begpos),
                                       gfapy.posvalue(endpos)))
    if gfapy.isfirstpos(begpos):
      if gfapy.isfirstpos(endpos):
        return ("pfx", True)
      elif gfapy.islastpos(endpos):
        return ("whole", False)
      else:
        return ("pfx", False)
    elif gfapy.islastpos(begpos):
      if not gfapy.islastpos(endpos):
        raise gfapy.FormatError(
          "Line: {}\n".format(str(self))+
          "Wrong use of $ marker\n"+
          "{} >= {}$".format(gfapy.posvalue(endpos),
                             gfapy.posvalue(begpos)))
      return ("sfx", True)
    else:
      if gfapy.islastpos(endpos):
        return ("sfx", False)
      else:
        return ("internal",
            gfapy.posvalue(begpos) == gfapy.posvalue(endpos))
