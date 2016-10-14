# A fragment line of a GFA2 file
class RGFA::Line::Fragment < RGFA::Line

  RECORD_TYPE = :F
  POSFIELDS = {:"1.0" => nil,
               :"2.0" => [:sid, :or, :external, :s_beg, :s_end,
                          :f_beg, :f_end, :alignment]}
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :sid => :any,
    :or => :any,
    :external => :any,
    :s_beg => :any,
    :s_end => :any,
    :f_beg => :any,
    :f_end => :any,
    :alignment => :any
  }

  define_field_methods!

end
