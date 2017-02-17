# A containment line of a RGFA file
# @tested_in api_positionals, api_references_edges_gfa1
class RGFA::Line::Edge::Containment < RGFA::Line::Edge

  RECORD_TYPE = :C
  POSFIELDS = [:from_segment, :from_orient, :to_segment, :to_orient, :pos, :overlap]
  FIELD_ALIAS = {:container => :from_segment,
                 :contained => :to_segment,
                 :from => :from_segment,
                 :to => :to_segment,
                 :container_orient => :from_orient,
                 :contained_orient => :to_orient}
  PREDEFINED_TAGS = [:MQ, :NM]
  DATATYPE = {
     :from_segment => :segment_name_gfa1,
     :from_orient => :orientation,
     :to_segment => :segment_name_gfa1,
     :to_orient => :orientation,
     :pos => :position_gfa1,
     :overlap => :alignment_gfa1,
     :MQ => :i,
     :NM => :i,
  }
  NAME_FIELD = nil
  STORAGE_KEY = nil
  REFERENCE_FIELDS = [:from_segment, :to_segment]
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

  apply_definitions
end

require_relative "common/from_to"
require_relative "common/alignment_type"
require_relative "gfa1/to_gfa2"
require_relative "gfa1/references"
require_relative "gfa1/oriented_segments"
require_relative "gfa1/alignment_type"
require_relative "gfa1/other"
require_relative "containment/canonical"
require_relative "containment/pos"
require_relative "containment/to_gfa2"

class RGFA::Line::Edge::Containment
  include RGFA::Line::Edge::Common::FromTo
  include RGFA::Line::Edge::Common::AlignmentType
  include RGFA::Line::Edge::GFA1::ToGFA2
  include RGFA::Line::Edge::GFA1::References
  include RGFA::Line::Edge::GFA1::OrientedSegments
  include RGFA::Line::Edge::GFA1::AlignmentType
  include RGFA::Line::Edge::GFA1::Other
  include RGFA::Line::Edge::Containment::Canonical
  include RGFA::Line::Edge::Containment::Pos
  include RGFA::Line::Edge::Containment::ToGFA2
end
