# An unordered group line of a GFA2 file
class RGFA::Line::UnorderedGroup < RGFA::Line

  RECORD_TYPE = :U
  POSFIELDS = [:pid, :items]
  REFERENCE_FIELDS = [:items]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {}
  DATATYPE = {
    :pid => :optional_identifier_gfa2,
    :items => :identifier_list_gfa2,
  }

  define_field_methods!

end
