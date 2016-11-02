# A gap line of a GFA2 file
class RGFA::Line::Gap < RGFA::Line

  RECORD_TYPE = :G
  POSFIELDS = [:gid, :sid1, :d1, :d2, :sid2, :disp, :var]
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :gid => :optional_identifier_gfa2,
    :sid1 => :identifier_gfa2,
    :d1 => :direction,
    :d2 => :direction,
    :sid2 => :identifier_gfa2,
    :disp => :i,
    :var => :optional_integer
  }

  define_field_methods!

end
