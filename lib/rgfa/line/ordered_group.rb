# An ordered group line of a GFA2 file
class RGFA::Line::OrderedGroup < RGFA::Line

  RECORD_TYPE = :O
  POSFIELDS = [:pid, :items]
  REFERENCE_FIELDS = [:items]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {:id => :pid}
  DATATYPE = {
    :pid => :optional_identifier_gfa2,
    :items => :identifier_list_gfa2,
  }

  define_field_methods!

end
