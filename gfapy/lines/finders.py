import gfapy

class Finders:
  def segment(self, s):
    """Search a segment in a GFA.

    If the argument is a line, it is returned. If it is a string,
    it is used as a segment identifier, and the segment with that identifier
    is returned. If no segment has the identifier, None is returned.
    Note that None is also returned if a line of another type (not segment)
    has the identifier (differently from the line() method, which returns
    the lines independently from the record type).

    Parameters:
      l (str, gfapy.Line)
    """
    if isinstance(s, gfapy.Line):
      return s
    else:
      return self._records["S"].get(s, None)

  def try_get_segment(self, s):
    """Call segment() and raise an exception is the segment is not found."""
    seg = self.segment(s)
    if seg is None:
      raise gfapy.NotFoundError("No segment has name {}".format(s))
    else:
      return seg

  RECORDS_WITH_NAME = ["E", "S", "P", "U", "G", "O", "\n"]

  def line(self, l):
    """Search a line in a GFA.

    If the argument is a line, it is returned. If it is a string,
    it is used as a line identifier, and the line with that identifier
    is returned. If no line has the identifier, None is returned.

    Parameters:
      l (str, gfapy.Line)
    """
    if gfapy.is_placeholder(l):
      return None
    elif isinstance(l, gfapy.Line):
      return l
    elif isinstance(l, str):
      return self.__line_by_name(l)
    else:
      return None

  def try_get_line(self, l):
    """Call line() and raise an exception is the line is not found."""
    gfa_line = self.line(l)
    if gfa_line is None:
      if gfapy.is_placeholder(l):
        raise gfapy.ValueError(
          "'*' is a placeholder and not a valid name for a line")
      else:
        raise gfapy.NotFoundError(
            "No line found with ID {}".format(l))
    return gfa_line

  def fragments_for_external(self, external_id):
    """List of F lines with a given external ID."""
    return list(self._records["F"].get(external_id,{}).values())

  def select(self, dict_or_line):
    """Select all lines which respect a chriterion.

    The chriterion is expressed by the argument, which is either a line
    instance or a dictionary. If it is a dictionary, it shall contain
    pairs of fieldnames/values and the method returns all lines
    where the mentioned fieldnames have the corresponding values.
    If it is a line, it is compared with the lines of the same type
    in the Gfa instance and lines with the same field values
    are returned (undefined placeholder values are thereby not compared).
    """
    is_dict = isinstance(dict_or_line, dict)
    name = dict_or_line.get("name",None) if is_dict else dict_or_line.get("name")
    if name is not None and not gfapy.is_placeholder(name):
      collection = [self.__line_by_name(name)]
    else:
      if is_dict:
        record_type = dict_or_line.get("record_type",None)
      else:
        record_type = dict_or_line.record_type
      collection = self.__collection_for_select(record_type)
    method = "_has_field_values" if is_dict else "_has_eql_fields"
    return [line for line in collection \
        if getattr(line, method)(dict_or_line, ["record_type","name"])]

  def _search_duplicate(self, gfa_line):
    if gfa_line.record_type == "L":
      return self._search_link(gfa_line.oriented_from, gfa_line.oriented_to,
                               gfa_line.alignment)
    elif gfa_line.record_type in self.RECORDS_WITH_NAME:
      return self.line(gfa_line.name)
    else:
      return None

  def _search_link(self, orseg1, orseg2, cigar):
    s = self.segment(orseg1.line)
    if s is None:
      return None
    for l in s.dovetails:
      if isinstance(l, gfapy.line.edge.Link) and \
          l.is_compatible(orseg1, orseg2, cigar, True):
        return l
    return None

  def __line_by_name(self, name):
    for rt in self.RECORDS_WITH_NAME:
      if rt not in self._records:
        next
      found = self._records[rt].get(name, None)
      if found is not None:
        return found
    return None

  def __collection_for_select(self, record_type):
    if record_type is None:
      return self.lines
    else:
      d = self._records[record_type]
      if record_type == "F":
        retval = []
        for v in d.values():
          retval.extend(list(v.values()))
        return retval
      else:
        return list(d.values())
