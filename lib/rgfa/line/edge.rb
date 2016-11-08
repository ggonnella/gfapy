# An edge line of a GFA2 file
class RGFA::Line::Edge < RGFA::Line

  RECORD_TYPE = :E
  POSFIELDS = [:eid, :sid1, :or2, :sid2, :beg1,
               :end1, :beg2, :end2, :alignment]
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
  FIELD_ALIAS = { :id => :eid }
  REFERENCE_FIELDS = [:sid1, :or2, :sid2, :beg1, :end1, :beg2, :end2]
  DEPENDENT_REFERENCES = [:paths, :subgraphs]
  NONDEPENDENT_REFERENCES = []

  define_field_methods!

end

require_relative "connection/ends_gfa1.rb"
require_relative "connection/alignment_type.rb"
require_relative "connection/gfa2_to_gfa1.rb"
require_relative "connection/alignment_type_gfa2.rb"

class RGFA::Line::Edge
  include RGFA::Line::Connection::EndsGFA1
  include RGFA::Line::Connection::AlignmentType
  include RGFA::Line::Connection::AlignmentTypeGFA2
  include RGFA::Line::Connection::GFA2ToGFA1
end
