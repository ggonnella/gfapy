from .line import Line

class Unknown(Line):
  """
  A GFA2 line which was referred to only by G or O lines
  and has not been found yet (ie is always virtual)
  """

  RECORD_TYPE = None
  POSFIELDS = ["name"]
  FIELD_ALIAS = { }
  PREDEFINED_TAGS = []
  DATATYPE = {
      "name" : "identifier_gfa2",
  }
  REFERENCE_FIELDS = []
  NAME_FIELD = "name"
  STORAGE_KEY = "name"
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = ["sets", "paths"]
  OTHER_REFERENCES = []

  def __str__(self):
    return "?record_type?\t{}\tco:Z:line_created_by_gfapy".format(self.name)

  @property
  def virtual(self):
    return True

Unknown._apply_definitions()