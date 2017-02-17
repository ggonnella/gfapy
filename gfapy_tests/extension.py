import gfapy
import re

class Taxon(gfapy.Line):

  RECORD_TYPE = "T"
  POSFIELDS = ["tid", "desc"]
  PREDEFINED_TAGS = ["UL"]
  DATATYPE = {
    "tid":"identifier_gfa2",
    "desc":"Z",
    "UL":"Z",
  }
  NAME_FIELD = "tid"
  STORAGE_KEY = "name"
  FIELD_ALIAS = {}
  REFERENCE_FIELDS = []
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = ["metagenomic_assignments"]
  OTHER_REFERENCES = []

Taxon._apply_definitions()

class MetagenomicAssignment(gfapy.Line):

  RECORD_TYPE = "M"
  POSFIELDS = ["mid", "tid", "sid", "score"]
  PREDEFINED_TAGS = []
  DATATYPE = {
    "mid":"optional_identifier_gfa2",
    "tid":"identifier_gfa2",
    "sid":"identifier_gfa2",
    "score":"optional_integer",
  }
  NAME_FIELD = "mid"
  STORAGE_KEY = "name"
  FIELD_ALIAS = {}
  REFERENCE_FIELDS = ["tid", "sid"]
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

  def _initialize_references(self):
    s = self.gfa.segment(self.sid)
    if s is None:
      s = gfapy.line.segment.GFA2([self.sid, "1", "*"],
                                   virtual=True, version="gfa2")
      s.connect(self.gfa)
    self._set_existing_field("sid", s, set_reference=True)
    s._add_reference(self, "metagenomic_assignments")

    t = self.gfa.line(self.tid)
    if t is None:
      t = Taxon([self.tid, "*"],
                virtual=True, version="gfa2")
      t.connect(self.gfa)
    self._set_existing_field("tid", t, set_reference=True)
    t._add_reference(self, "metagenomic_assignments")

MetagenomicAssignment._apply_definitions()

gfapy.line.segment.GFA2.DEPENDENT_LINES.append("metagenomic_assignments")
gfapy.line.segment.GFA2._define_reference_getters()
gfapy.Line.EXTENSIONS["M"] = MetagenomicAssignment
gfapy.Line.EXTENSIONS["T"] = Taxon
gfapy.Line.RECORD_TYPE_VERSIONS["specific"]["gfa2"].append("M")
gfapy.Line.RECORD_TYPE_VERSIONS["specific"]["gfa2"].append("T")
gfapy.lines.finders.Finders.RECORDS_WITH_NAME.append("T")
gfapy.lines.finders.Finders.RECORDS_WITH_NAME.append("M")

class TaxonID:

  def validate_encoded(string):
    if not re.match(r"^taxon:(\d+)$",string) and \
        not re.match(r"^[a-zA-Z0-9_]+$", string):
      raise gfapy.ValueError("Invalid taxon ID: {}".format(string))

  def unsafe_decode(string):
    return string

  def decode(string):
    TaxonID.validate_encoded(string)
    return string

  def validate_decoded(obj):
    if isinstance(obj,Taxon):
      TaxonID.validate_encoded(obj.name)
      return obj.name
    if isinstance(obj,str):
      TaxonID.validate_encoded(obj)
      return obj
    else:
      raise gfapy.TypeError(
        "Invalid type for taxon ID: "+"{}".format(repr(obj)))

  def unsafe_encode(obj):
    if isinstance(obj, Taxon):
      obj = obj.name
    return obj

  def encode(obj):
    TaxonID.validate_decoded(obj)
    return TaxonID.unsafe_encode(obj)

gfapy.Field.GFA2_POSFIELD_DATATYPE.append("taxon_id")
gfapy.Field.FIELD_MODULE["taxon_id"] = TaxonID
Taxon.DATATYPE["tid"] = "taxon_id"
MetagenomicAssignment.DATATYPE["tid"] = "taxon_id"
