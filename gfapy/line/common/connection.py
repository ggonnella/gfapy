import gfapy

class Connection:

  def is_connected(self):
    """
    In a connected line, some of the fields are converted
    into references or a list of references to other lines.
    Furthermore instance variables are populated with back
    references to the line (e.g. connection of a segment
    are stored as references in segment arrays), to allow
    graph traversal.

    Returns
    -------
    bool
      Is the line connected to other lines of a GFA instance?
    """
    return (self._gfa is not None)

  @property
  def gfa(self):
    return self._gfa

  def connect(self, gfa):
    """
    Connect the line to a GFA instance

    Parameters
    ----------
    gfa : GFA
      the GFA instance

    Returns
    -------
    None
    """
    if self.is_connected():
      raise gfapy.RuntimeError(
        "Line {} is already connected to a GFA instance".format(self))
    previous = gfa._search_duplicate(self)
    if previous:
      if previous.virtual:
        return self._substitute_virtual_line(previous)
      else:
        return self._process_not_unique(previous)
    else:
      self._gfa = gfa
      self._initialize_references()
      self._gfa._register_line(self)
      return None

  @property
  def all_references(self):
    """List of lines which contain references to the line instance

    Returns
    -------
    list
    """
    if not self._refs:
      self._refs = {}
    return [x for y in self._refs.values() for x in y]

  def _add_reference(self, line, key, append = True):
    if not self._refs:
      self._refs = {}
    if key not in self._refs:
      self._refs[key] = []
    if append:
      self._refs[key].append(line)
    else:
      self._refs[key].insert(0, line)

  def _initialize_references(self):
    """
    .. note::
      SUBCLASSES with reference fields shall
      overwrite this method to connect their reference
      fields
    """
    if self.REFERENCE_INITIALIZERS:
      for field, klass, refkey in self.REFERENCE_INITIALIZERS:
        self._initialize_reference(field, klass, refkey)

  def _initialize_reference(self, field, klass, refkey):
    name = self.get(field)
    line = self.gfa.line(name)
    if line is None:
      data = [klass.RECORD_TYPE]
      for i in range(len(klass.POSFIELDS)):
        data.append("1")
      line = klass(data, virtual=True, version="gfa2")
      line.name = name
      line.connect(self.gfa)
    self._set_existing_field(field, line, set_reference=True)
    line._add_reference(self, refkey)

  def _process_not_unique(self, previous):
    """
    .. note::
      SUBCLASSES may overwrite this method
      if some kind of non unique lines shall be
      tolerated or handled differently (eg complement links)
    """
    raise gfapy.NotUniqueError(
      "Line: {}\n".format(str(self))+
      "Line or ID not unique\n"+
      "Matching previous line: {}".format(str(previous))
      )
