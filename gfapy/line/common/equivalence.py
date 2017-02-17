import gfapy

class Equivalence:

  def __hash__(self):
    name = self.get("name")
    if name:
      return name.__hash__()
    else:
      return NotImplemented

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
    gfapy.line.edge.Link.__eq__
    """
    if o is self:
      return True
    if isinstance(o, str):
      name = self.get("name")
      if name:
        return name == str(o)
    if not isinstance(o, gfapy.Line):
      return False
    if (o.record_type != self.record_type):
      return False
    if sorted(o._data.keys()) != sorted(self._data.keys()):
      return False
    for k,v in o._data.items():
      if self._data[k] != v:
        if self.field_to_s(k) != o.field_to_s(k):
          return False
    return True

  def diff(self, other):
    if self.record_type != other.record_type:
      return ("incompatible", "record_type", \
              self.record_type, other.record_type)
    if self.__class__ != other.__class__:
      if self.version == other.version:
        raise gfapy.AssertionError
      return ("incompatible", "version", self.version, other.version)
    differences = []
    for fieldname in self.positional_fieldnames:
      value1 = self.field_to_s(fieldname)
      value2 = other.field_to_s(fieldname)
      if value1 != value2:
        differences.append(("different", "positional_field",
                            fieldname, value1, value2))
    for tagname in other.tagnames:
      if tagname not in self.tagnames:
        differences.append(("exclusive", ">", "tag",
                      tagname, other.get_datatype(tagname),
                      other.get(tagname)))
    for tagname in self.tagnames:
      if tagname not in other.tagnames:
        differences.append(("exclusive", "<", "tag",
                      tagname, self.get_datatype(tagname), self.get(tagname)))
      else:
        tag1 = self.field_to_s(tagname, tag=True)
        tag2 = other.field_to_s(tagname, tag=True)
        if tag1 != tag2:
          differences.append(("different", "tag", tagname,
                          self.get_datatype(tagname),
                          self.field_to_s(tagname),
                          other.get_datatype(tagname),
                          other.field_to_s(tagname)))
    return differences

  def diffscript(self, other, selfvar):
    outscript = []
    for diffitem in self.diff(other):
      if diffitem[0] == "incompatible":
        if diffitem[1] == "record_type":
          raise gfapy.RuntimeError(
            "Cannot compute conversion script: different record type\n"+
            "Line: {}\n".format(self)+
            "Other: {}\n".format(other)+
            "{0} != {1}",format(diffitem[2], diffitem[3]))
        elif diffitem[1] == "version":
          raise gfapy.RuntimeError(
            "Cannot compute conversion script: different GFA version\n"+
            "Line: {}\n".format(self)+
            "Other: {}\n".format(other)+
            "{0} != {1}",format(diffitem[2], diffitem[3]))
      elif diffitem[0] == "different":
        if diffitem[1] == "positional_field":
          outscript.append("{0}.set('{1}', '{2}')".format(selfvar,
                                      diffitem[2].replace("'","\\'"),
                                      diffitem[4].replace("'","\\'")))
        elif diffitem[1] == "tag":
          if diffitem[3] != diffitem[5]:
            outscript.append("{0}.set_datatype('{1}', '{2}')".format(selfvar,
                                      diffitem[2].replace("'","\\'"),
                                      diffitem[5].replace("'","\\'")))
          if diffitem[4] != diffitem[6]:
            outscript.append("{0}.set('{1}', '{2}')".format(selfvar,
                                      diffitem[2].replace("'","\\'"),
                                      diffitem[6].replace("'","\\'")))
      elif diffitem[0] == "exclusive":
        if diffitem[1] == ">":
          if diffitem[2] == "tag":
            outscript.append("{0}.set_datatype('{1}', '{2}')".format(selfvar,
                                      diffitem[3].replace("'","\\'"),
                                      diffitem[4].replace("'","\\'")))
            outscript.append("{0}.set('{1}', '{2}')".format(selfvar,
                                      diffitem[3].replace("'","\\'"),
                                      diffitem[5].replace("'","\\'")))
        elif diffitem[1] == "<":
          if diffitem[2] == "tag":
            outscript.append("{0}.delete('{1}')".format(selfvar,
                                      diffitem[3].replace("'","\\'")))
    return "\n".join(outscript)


  def _has_field_values(self, hsh, ignore_fields = None):
    assert(isinstance(hsh, dict))
    if ignore_fields is None:
      ignore_fields = []
    if ("record_type" in hsh) and ("record_type" not in ignore_fields) \
        and (self.record_type != hsh["record_type"]):
      return False
    ignore_fields.append("record_type")
    fieldnames = [i for i in hsh.keys() if i not in ignore_fields]
    for fieldname in fieldnames:
      value = self.get(fieldname)
      if value is None:
        return False
      if gfapy.is_placeholder(value):
        continue
      if value != hsh[fieldname] and \
          (self.field_to_s(fieldname) != hsh[fieldname]):
        return False
    return True

  def _has_eql_fields(self, refline, ignore_fields = None):
    assert(isinstance(refline, gfapy.Line))
    if ignore_fields is None:
      ignore_fields = []
    self._dealias_fieldnames(ignore_fields)
    if ("record_type" not in ignore_fields) \
        and (self.record_type != refline.record_type):
      return False
    fieldnames = refline.positional_fieldnames + refline.tagnames
    fieldnames = [i for i in fieldnames if i not in ignore_fields]
    if "name" in ignore_fields:
      name_field = refline.__class__.NAME_FIELD
      if name_field in fieldnames:
        fieldnames.remove(name_field)
    for fieldname in fieldnames:
      refvalue = refline.get(fieldname)
      if gfapy.is_placeholder(refvalue):
        continue
      value = self.get(fieldname)
      if value is None:
        return False
      if gfapy.is_placeholder(value):
        continue
      if value != refvalue:
        return False
    return True
