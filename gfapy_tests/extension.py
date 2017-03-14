import gfapy
import re

class Taxon(gfapy.Line):
  RECORD_TYPE = "T"
  POSFIELDS = ["tid"]
  DATATYPE = { "tid":"identifier_gfa2",
               "UL":"Z" }
  NAME_FIELD = "tid"

Taxon.register_extension()

class MetagenomicAssignment(gfapy.Line):
  RECORD_TYPE = "M"
  POSFIELDS = ["mid", "tid", "sid"]
  DATATYPE = {
    "mid":"optional_identifier_gfa2",
    "tid":"identifier_gfa2",
    "sid":"identifier_gfa2",
    "SC":"i",
  }
  NAME_FIELD = "mid"

MetagenomicAssignment.register_extension(references=
    [("sid", gfapy.line.segment.GFA2, "metagenomic_assignments"),
     ("tid", Taxon, "metagenomic_assignments")])

class TaxonID:

  def validate_encoded(string):
    if not re.match(r"^taxon:(\d+)$",string) and \
        not re.match(r"^[a-zA-Z0-9_]+$", string):
      raise gfapy.ValueError("Invalid taxon ID: {}".format(string))

  def decode(string):
    TaxonID.validate_encoded(string)
    return string

  def validate_decoded(obj):
    if isinstance(obj,Taxon):
      TaxonID.validate_encoded(obj.name)
    else:
      raise gfapy.TypeError(
        "Invalid type for taxon ID: "+"{}".format(repr(obj)))

  def encode(obj):
    TaxonID.validate_decoded(obj)
    return obj

gfapy.Field.register_datatype("taxon_id", TaxonID)

Taxon.DATATYPE["tid"] = "taxon_id"
MetagenomicAssignment.DATATYPE["tid"] = "taxon_id"
