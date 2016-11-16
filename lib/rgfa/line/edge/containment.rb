# A containment line of a RGFA file
class RGFA::Line::Edge::Containment < RGFA::Line::Edge

  RECORD_TYPE = :C
  POSFIELDS = [:from, :from_orient, :to, :to_orient, :pos, :overlap]
  FIELD_ALIAS = {:container => :from,
                 :contained => :to,
                 :container_orient => :from_orient,
                 :contained_orient => :to_orient}
  PREDEFINED_TAGS = [:MQ, :NM]
  DATATYPE = {
     :from => :segment_name_gfa1,
     :from_orient => :orientation,
     :to => :segment_name_gfa1,
     :to_orient => :orientation,
     :pos => :position_gfa1,
     :overlap => :alignment_gfa1,
     :MQ => :i,
     :NM => :i,
  }
  REFERENCE_FIELDS = [:from, :to]
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

  define_field_methods!
end

require_relative "common/from_to"
require_relative "common/alignment_type"
require_relative "gfa1/to_gfa2"
require_relative "gfa1/references"
require_relative "containment/canonical"
require_relative "containment/pos"

class RGFA::Line::Edge::Containment
  include RGFA::Line::Edge::Common::FromTo
  include RGFA::Line::Edge::Common::AlignmentType
  include RGFA::Line::Edge::GFA1::ToGFA2
  include RGFA::Line::Edge::GFA1::References
  include RGFA::Line::Edge::Containment::Canonical
  include RGFA::Line::Edge::Containment::Pos
end
