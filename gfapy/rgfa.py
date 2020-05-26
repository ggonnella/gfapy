import gfapy

class RGFA():
  """
  Add support of rGFA format.
  A dialect-specific validation method is added, as well as convenience
  methods to handle the stable sequence names.
  """

  def is_rgfa(self):
    """
    Indicate that rGFA dialect of GFA1 shall be used
    """
    return self._dialect == "rgfa"

  @property
  def stable_sequence_names(self):
    """Stable sequence names from rGFA SN tags"""
    if self._dialect != "rgfa":
      return []
    stable_seqs = set()
    for s in self.segments:
      stable_seqs.add(s.SN)
    return list(stable_seqs)

  def validate_rgfa(self):
    """
    Validate rGFA

    - version must be 1.0
    - no H, P, C lines are present
    - S lines have rGFA-specific predefined tags
    - if L lines have rGFA-specific tags, they have the correct type
    - overlaps must be 0M
    """
    self._validate_rgfa_version()
    self._validate_rgfa_no_headers()
    self._validate_rgfa_no_containments()
    self._validate_rgfa_no_paths()
    self._validate_rgfa_tags_in_lines(self.segments)
    self._validate_rgfa_tags_in_lines(self.dovetails)
    self._validate_rgfa_link_overlaps()

  def _validate_rgfa_version(self):
    """Validate version of rGFA (it must be gfa1)"""
    if self.version != "gfa1":
      raise gfapy.VersionError("rGFA format only supports GFA version 1")

  def _validate_rgfa_no_headers(self):
    """Validate the absence of H lines in rGFA"""
    if self.headers:
      raise gfapy.ValueError("rGFA does not support header lines")

  def _validate_rgfa_no_containments(self):
    """Validate the absence of C lines in rGFA"""
    if self.containments:
      raise gfapy.ValueError("rGFA does not support containment lines")

  def _validate_rgfa_no_paths(self):
    """Validate the absence of P lines in rGFA"""
    if self.paths:
      raise gfapy.ValueError("rGFA does not support path lines")

  RGFA_TAGS = {
    "mandatory": {
        "S": {"SN": "Z", "SO": "i", "SR": "i"},
        "L": {},
      },
    "optional": {
      "S": {},
      "L": {"SR": "i", "L1": "i", "L2": "i"},
      },
    }

  def _validate_rgfa_tags_in_lines(self, lines):
    """
    Validate rGFA tags for a group of lines
    """
    for line in lines:
      rt = line.record_type
      tags_check_presence = gfapy.Gfa.RGFA_TAGS["mandatory"].get(rt, {})
      tags_check_datatype = tags_check_presence.copy()
      tags_check_datatype.update(gfapy.Gfa.RGFA_TAGS["optional"].get(rt,{}))
      for tag, datatype in tags_check_presence.items():
        if tag not in line.tagnames:
          raise gfapy.NotFoundError(
            "rGFA {} lines must have a {} tag\n".format(rt, tag)+
            "offending line:\n{}".format(str(line)))
      for tag, datatype in tags_check_datatype.items():
        if tag in line.tagnames:
          if line.get_datatype(tag) != datatype:
            raise gfapy.ValueError(
              "rGFA {} tags in {} lines must have datatype {}\n".format(
                tag, rt, datatype)+
              "offending line:\n{}".format(str(line)))

  def _validate_rgfa_link_overlaps(self):
    for link in self.dovetails:
      if link.field_to_s("overlap") != "0M":
        raise gfapy.ValueError("rGFA CIGARs must be 0M\n",
              "offending line:\n{}".format(str(link)))
