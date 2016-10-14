# An edge line of a GFA2 file
class RGFA::Line::Edge < RGFA::Line

  RECORD_TYPE = :E
  POSFIELDS = {:"1.0" => nil,
               :"2.0" => [:eid, :sid1, :or2, :sid2, :beg1,
                          :end1, :beg2, :end2, :alignment]}
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :eid => :any,
    :sid1 => :any,
    :or2 => :any,
    :sid2 => :any,
    :beg1 => :any,
    :end1 => :any,
    :beg2 => :any,
    :end2 => :any,
    :alignment => :any
  }

  define_field_methods!

end
