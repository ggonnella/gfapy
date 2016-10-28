# An ordered group line of a GFA2 file
class RGFA::Line::OrderedGroup < RGFA::Line

  RECORD_TYPE = :O
  POSFIELDS = [:pid, :items]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {}
  DATATYPE = {
    :pid => :optional_identifier_gfa2,
    :items => :identifier_list_gfa2,
  }

  define_field_methods!

end
