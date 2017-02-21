import gfapy
from .lines import Lines
from .graph_operations import GraphOperations
from collections import defaultdict
import sys

class Gfa(Lines,GraphOperations):
  def __init__(self, vlevel = 1, version = None):
    self._vlevel = vlevel
    self._records = defaultdict(dict)
    self._records["H"] = gfapy.line.Header([], vlevel = vlevel)
    self._records["H"].connect(self)
    self._records["S"] = {}
    self._records["P"] = {}
    self._records["F"] = {}
    self._records[None] = {}
    self._records["E"] = {}
    self._records["U"] = {}
    self._records["G"] = {}
    self._records["O"] = {}
    self._records["C"] = {}
    self._records["L"] = {}
    self._records["#"] = {}
    self._segments_first_order = False
    self._progress = None
    self._default = {"count_tag": "RC", "unit_length": 1}
    self._line_queue = []
    if version is None:
      self._version = None
      self._version_explanation = None
      self._version_guess = "gfa2"
    else:
      self._version = version
      self._version_explanation = "set during initialization"
      self._version_guess = version
      self._validate_version()

  @property
  def version(self):
    return self._version

  @version.setter
  def version(self,value):
    self._vlevel=value

  @property
  def vlevel(self):
    return self._vlevel

  @vlevel.setter
  def vlevel(self,value):
    self._vlevel=value

  def validate(self):
    self.__validate_segment_references()
    self.__validate_path_links()
    return None

  def __str__(self):
    return "\n".join([str(line) for line in self.lines])

  # TODO: implement equivalent of to_gfa1_s, to_gfa2_s, to_gfa1, to_gfa2

  # TODO: implement clone (see how clone for lines was implemented)

  def read_file(self, filename):
    # TODO: better implementation of linecount
    if self._progress:
      linecount = 0
      with open(filename) as f:
        for line in f:
          linecount += 1
      self._progress_log_init("read_file", "lines", linecount,
                              "Parsing file {}".format(filename)+
                              " containing {} lines".format(linecount))
    with open(filename) as f:
      for line in f:
        self.add_line(line.rstrip('\r\n'))
        if self._progress:
          self._progress_log("read_file")
    if self._line_queue:
      self._version = self._version_guess
      self.process_line_queue()
    if self._progress:
      self._progress_log_end("read_file")
    if self._vlevel >= 1:
      self.validate()
    return self

  @classmethod
  def from_file(cls, filename, vlevel = 1, version = None):
    gfa = cls(vlevel = vlevel, version = version)
    gfa.read_file(filename)
    return gfa

  def to_file(self, filename):
    with open(filename, "w") as f:
      for line in self.lines:
        f.write(l+"\n")

  def __eq__(self, other):
    self.lines == other.lines

  def __lenstats(self):
    sln = [ s.try_length for s in self.segments ]
    sln = sorted(sln)
    n = len(sln)
    tlen = 0
    for l in sln:
      tlen += l
    n50_target = tlen//2
    n50 = None
    curr_sum = 0
    for l in reversed(sln):
      curr_sum += l
      if curr_sum >= n50_target:
        n50 = l
        break
    q = (sln[0], sln[(n//4)-2], sln[(n//2)-1], sln[((n*3)//4)-1], sln[-1])
    return (q, n50, tlen)

  def __validate_segment_references(self):
    for s in self.segments:
      if s.virtual:
        raise gfapy.NotFoundError("Segment {}".format(s.name)+
            "does not exist\nReferences to {}".format(s.name)+
            "were found in some lines")
        # TODO: output list of lines where references were found
    return None

  def __validate_path_links(self):
    for pt in self.gfa1_paths:
      for ol in pt.links:
        l = ol.line
        if l.virtual:
          raise gfapy.NotFoundError("Link {}".format(str(l))+
            "does not exist, but is required by some paths")
          # TODO: output list of lines where references were found
    return None

  def _validate_version(self):
    if (self._version != None) and (self._version not in gfapy.VERSIONS):
      raise gfapy.VersionError("GFA specification version {} not supported".
              format(self._version))

  @classmethod
  def from_string(cls, string, vlevel=1, version=None):
    return cls.from_list(string.split("\n"), vlevel=vlevel, version=version)

  @classmethod
  def from_list(cls, lines_array, vlevel=1, version=None):
    gfa = cls(vlevel=vlevel, version=version)
    for line in lines_array:
      gfa.add_line(line)
    gfa.process_line_queue()
    if vlevel >= 1:
      gfa.validate()
    return gfa

  # Progress logging related-methods:

  def enable_progress_logging(self, part=0.1, channel=sys.stderr):
    '''Activate logging of progress'''
    self._progress = gfapy.Logger(channel=channel)
    self._progress.enable_progress(part=part)

  def _progress_log_init(self, symbol, units, total, initmsg = None):
    if self._progress is not None:
      self._progress.progress_init(symbol, units, total, initmsg)

  def _progress_log(self, symbol, progress=1, **keyargs):
    if self._progress is not None:
      self._progress.progress_log(symbol, progress)

  def _progress_log_end(self, symbol, **keyargs):
    if self._progress is not None:
      self._progress.progress_end(symbol)

