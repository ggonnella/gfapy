import gfapy

class AlignmentType:

  @property
  def alignment_type(self):
    """
    Returns
    -------
    "C" or "L" or "I"
    	**"C"** if containment, **"L"** if link,
      **"I"** (internal) if any other local alignment.
    """
    st1 = self._substring_type(self.beg1, self.end1)[0]
    st2 = self._substring_type(self.beg2, self.end2)[0]
    return self._alignment_type_for_substring_types(st1, st2)

  def _alignment_type_for_substring_types(self, st1, st2):
    """
    Parameters
    ----------
    st1 : substring_type
    	value for sid1
    st2 : substring_type
    	value for sid2

    Returns
    -------
    "C" or "L" or "I"
    	**"C"** if containment, **"L"** if link,
      **"I"** (internal) if any other local alignment.
    """
    if st1 == "whole" or st2 == "whole":
      return "C"
    elif self.sid1.orient == self.sid2.orient:
      if (st1 == "pfx" and st2 == "sfx") or (st1 == "sfx" and st2 == "pfx"):
        return "L"
      else:
        return "I"
    else:
      if (st1 == "pfx" or st2 == "sfx") and (st1 == st2):
        return "L"
      else:
        return "I"

  def _substring_type(self, begpos, endpos):
    """
    Analyze the begin and end position and determine if the substring is
    the whole string, or a (possibly empty) other substring, ie a prefix,
    a suffix, or an internal alignment.

    Parameters
    ----------
    begpos : gfapy.LastPos
    	Begin position of the substring on a segment.
    endpos : gfapy.LastPos
    	End position of the substring on a segment.

    Returns
    -------
    (substring_type : str, bool) list
    	The first value is the substring type, which is 
      one of: "pfx", "sfx", "whole", "internal".
      Thereby, with "pfx" or "sfx" is meant a prefix or suffix 
      which is not the complete string. 
      With "internal" is meant a substring which starts after the first position
      and ends before the last position. 
      The second value is a boolean, **True** if the substring is empty, 
      **false** otherwise.
    """
    if gfapy.LastPos.get_value(begpos) > gfapy.LastPos.get_value(endpos):
      raise gfapy.ValueError(
        "Line: {}\n".format(str(self))+
        "begin > end: {}$ > {}".format(gfapy.LastPos.get_value(begpos), 
                                       gfapy.LastPos.get_value(endpos)))
    if gfapy.LastPos.get_is_first(begpos):
      if gfapy.LastPos.get_is_first(endpos):
        return ("pfx", True)
      elif gfapy.LastPos.get_is_last(endpos):
        return ("whole", False)
      else:
        return ("pfx", False)
    elif gfapy.LastPos.get_is_last(begpos):
      if not gfapy.LastPos.get_is_last(endpos):
        raise gfapy.FormatError(
          "Line: {}\n".format(str(self))+
          "Wrong use of $ marker\n"+
          "{} >= {}$".format(gfapy.LastPos.get_value(endpos), 
                             gfapy.LastPos.get_value(begpos)))
      return ("sfx", True)
    else:
      if gfapy.LastPos.get_is_last(endpos):
        return ("sfx", False)
      else:
        return ("internal", 
            gfapy.LastPos.get_value(begpos) == gfapy.LastPos.get_value(endpos))
