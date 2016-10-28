# A gap line of a GFA2 file
class RGFA::Line::Gap < RGFA::Line

  RECORD_TYPE = :G
  POSFIELDS = {:"1.0" => nil,
               :"2.0" => [:gid, :sid1, :or1, :sid2, :or2, :disp, :var]}
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :gid => :optional_identifier_gfa2,
    :sid1 => :identifier_gfa2,
    :or1 => :orientation,
    :sid2 => :identifier_gfa2,
    :or2 => :orientation,
    :disp => :generic,
    :var => :generic
  }

  define_field_methods!

end
