# A segment line of a RGFA file
class RGFA::Line::Segment::GFA1 < RGFA::Line::Segment

  RECORD_TYPE = :S
  POSFIELDS = [:name, :sequence]
  PREDEFINED_TAGS = [:LN, :RC, :FC, :KC, :SH, :UR]
  DATATYPE = {
    :name => :segment_name_gfa1,
    :sequence => :sequence_gfa1,
    :LN => :i,
    :RC => :i,
    :FC => :i,
    :KC => :i,
    :SH => :H,
    :UR => :Z,
  }
  FIELD_ALIAS = { :sid => :name }
  REFERENCE_FIELDS = []
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:dovetails_L, :dovetails_R,
                     :edges_to_contained, :edges_to_containers]
  gfa2_compatibility = [:gaps_L, :gaps_R, :fragments, :internals, :sets]
  OTHER_REFERENCES = [:paths] + gfa2_compatibility

  define_field_methods

  alias_method :to_sym, :name

end

require_relative "gfa1_to_gfa2"
require_relative "length_gfa1"
require_relative "coverage"
require_relative "references"
require_relative "writer_wo_sequence"

class RGFA::Line::Segment::GFA1
  include RGFA::Line::Segment::GFA1ToGFA2
  include RGFA::Line::Segment::LengthGFA1
  include RGFA::Line::Segment::Coverage
  include RGFA::Line::Segment::References
  include RGFA::Line::Segment::WriterWoSequence
end
