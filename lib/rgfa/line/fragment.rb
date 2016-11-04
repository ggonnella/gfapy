# A fragment line of a GFA2 file
class RGFA::Line::Fragment < RGFA::Line

  RECORD_TYPE = :F
  POSFIELDS = [:sid, :or, :external, :s_beg, :s_end, :f_beg, :f_end, :alignment]
  REFERENCE_FIELDS = [:sid]
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :sid => :identifier_gfa2,
    :or => :orientation,
    :external => :identifier_gfa2,
    :s_beg => :position_gfa2,
    :s_end => :position_gfa2,
    :f_beg => :position_gfa2,
    :f_end => :position_gfa2,
    :alignment => :alignment_gfa2
  }

  define_field_methods!

end
