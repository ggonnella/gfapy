import gfapy

class Construction:

  @property
  def positional_fieldnames(self):
    """The names of the positional fields.

    The property is implemented differently for CustomRecord
    instances, as the positional fieldnames are unknown.

    Returns:
      list of str
    """
    return self._positional_fieldnames

  @property
  def tagnames(self):
    """The names of the tags defined in the line.

    The property is implemented differently for CustomRecord
    instances, as tags are identified heuristically (as the number
    of positional fields is unknown).

    Returns:
      list of str
    """
    return[x for x in self._data.keys() \
             if (not x in self.positional_fieldnames) \
                 and (x != "record_type")]

  def _initialize_positional_fields(self, strings):
    """delayed, see #delayed_inizialize_positional_fields"""
    pass

  def _initialize_tags(self, strings):
    first_tag = len(strings)
    for i in range(len(strings)-1, 0, -1):
      try:
        self._initialize_tag(*(gfapy.Field._parse_gfa_tag(strings[i])))
      except:
        break
      first_tag = i
    self._delayed_initialize_positional_fields(strings, first_tag)

  def _delayed_initialize_positional_fields(self, strings, n_positional_fields):
    self._positional_fieldnames = []
    if strings[0] in ["P", "C", "L"]:
      raise gfapy.VersionError(
        "GFA-like line (P,C,L) found in GFA2\n"+
        "Line: {}\n".format(" ".join(strings))+
        "Custom lines with record_type P, C and L are not supported by gfapy.")
    self._init_field_value("record_type", "custom_record_type", strings[0],
                     errmsginfo = strings)
    for i in range(1, n_positional_fields):
      n = "field{}".format(i)
      self._init_field_value(n, "generic", strings[i], errmsginfo = strings)
      self.positional_fieldnames.append(n)
      self._datatype[n] = "generic"
