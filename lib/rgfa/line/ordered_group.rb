# An ordered group line of a GFA2 file
class RGFA::Line::OrderedGroup < RGFA::Line

  RECORD_TYPE = :O
  POSFIELDS = {:"1.0" => nil,
               :"2.0" => [:pid, :items]}
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {}
  DATATYPE = {
    :pid => :any,
    :items => :any,
  }

  define_field_methods!

end
