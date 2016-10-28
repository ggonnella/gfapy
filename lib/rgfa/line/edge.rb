# An edge line of a GFA2 file
class RGFA::Line::Edge < RGFA::Line

  RECORD_TYPE = :E
  POSFIELDS = [:eid, :sid1, :or2, :sid2, :beg1,
               :end1, :beg2, :end2, :alignment]
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :eid => :optional_identifier_gfa2,
    :sid1 => :identifier_gfa2,
    :or2 => :orientation,
    :sid2 => :identifier_gfa2,
    :beg1 => :position_gfa2,
    :end1 => :position_gfa2,
    :beg2 => :position_gfa2,
    :end2 => :position_gfa2,
    :alignment => :alignment_gfa2,
  }

  define_field_methods!

end
