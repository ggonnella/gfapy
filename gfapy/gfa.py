import gfapy

class Gfa:
  def __init__(self, vlevel = 1, version = None):
    self.vlevel = vlevel
    self.records = {}
    self.records["H"] = gfapy.Line.Header([], vlevel = vlevel)
    self.records["S"] = {}
    self.records["P"] = {}
    self.records["F"] = {}
    self.records[None] = {}
    self.records["E"] = {None: []}
    self.records["U"] = {None: []}
    self.records["G"] = {None: []}
    self.records["O"] = {None: []}
    self.records["C"] = []
    self.records["L"] = []
    self.records["#"] = []
    self.segments_first_order = False
    self.progress = False
    self.default = {"count_tag": "RC", "unit_length": 1}
    self.extensions_enabled = False
    self.line_queue = []
    if version == None:
      self.version = None
      self.version_explanation = None
      self.version_guess = "gfa2"
    else:
      self.version = version
      self.version_explanation = "set during initialization"
      self.version_guess = version
      self.__validate_version()

  def validate(self):
    self.__validate_segment_references()
    self.__validate_path_links()
    return None

  def __str__(self):
    s = ""
    for line in self.lines():
      s = s + line + "\n"
    return s

  # TODO: implement equivalent of to_gfa1_s, to_gfa2_s, to_gfa1, to_gfa2

  # TODO: implement clone (see how clone for lines was implemented)

  def read_file(self, filename):
    pass

  @classmethod
  def from_file(cls, filename):
    pass

  def __eq__(self, other):
    self.lines() == other.lines()

  def __lenstats(self):
    sln = [ s.try_length for s in self.segments() ]
    sln = sorted(sln)
    n = len(sln)
    tlen = 0
    for l in sln:
      tlen = tlen + l
    n50_target = tlen / 2
    n50 = None
    curr_sum = 0
    for l in reversed(sln):
      curr_sum = curr_sum + l
      if curr_sum >= n50_target:
        n50 = l
        break
    q = [sln[0], sln[(n/4)-2], sln[(n/2)-1], sln[((n*3)/4)-1], sln[-1]]
    return (q, n50, tlen)

  def __validate_segment_references(self):
    for s in self.segments():
      if s.is_virtual():
        raise gfapy.NotFoundError("Segment {}".format(s.name)+
            "does not exist\nReferences to {}".format(s.name)+
            "were found in some lines")
        # TODO: output list of lines where references were found
    return None

  def __validate_path_links(self):
    for pt in self.paths():
      for ol in pt.links():
        l = ol.line
        if l.is_virtual():
          raise gfapy.NotFoundError("Link {}".format(str(l))+
            "does not exist, but is required by some paths")
          # TODO: output list of lines where references were found
    return None

  def __validate_version(self):
    if (self.version != None) and (self.version not in gfapy.Gfa.VERSIONS):
      raise gfapy.VersionError("GFA specification version {} not supported".
              format(self.version))

  @classmethod
  def from_string(cls, vlevel = 1, version = None):
    pass

  @classmethod
  def from_list(cls, vlevel = 1, version = None):
    pass
