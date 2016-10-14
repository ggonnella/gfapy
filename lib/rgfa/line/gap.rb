# A gap line of a GFA2 file
class RGFA::Line::Gap < RGFA::Line

  RECORD_TYPE = :G
  REQFIELDS = {:"1.0" => nil,
               :"2.0" => [:gid, :sid1, :or1, :sid2, :or2, :disp, :var]}
  FIELD_ALIAS = {}
  PREDEFINED_OPTFIELDS = []
  DATATYPE = {
    :gid => :any,
    :sid1 => :any,
    :or1 => :any,
    :sid2 => :any,
    :or2 => :any,
    :disp => :any,
    :var => :any
  }

  define_field_methods!

end
