from ..group import Group

class Walk(Group):
  """A walk line of a GFA1.1 file"""
  RECORD_TYPE = "W"
  POSFIELDS = ["sample_id", "hap_index", "seq_id", "seq_start", "seq_end", "walk"]
  DATATYPE = {
    "sample_id": "
