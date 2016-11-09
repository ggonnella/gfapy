# An unordered group line of a GFA2 file
class RGFA::Line::Group::Unordered < RGFA::Line::Group

  RECORD_TYPE = :U
  POSFIELDS = [:pid, :items]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {:id => :pid}
  DATATYPE = {
    :pid => :optional_identifier_gfa2,
    :items => :identifier_list_gfa2,
  }
  REFERENCE_FIELDS = [:items]
  DEPENDENT_REFERENCES = []
  NONDEPENDENT_REFERENCES = []

  define_field_methods!

end
