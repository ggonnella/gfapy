# A link connects two segments, or a segment to itself.
# @tested_in api_positionals, api_references_edges_gfa1
class RGFA::Line::Edge::Link < RGFA::Line::Edge

  RECORD_TYPE = :L
  POSFIELDS = [:from, :from_orient, :to, :to_orient, :overlap]
  PREDEFINED_TAGS = [:MQ, :NM, :RC, :FC, :KC]
  FIELD_ALIAS = {}
  DATATYPE = {
     :from => :segment_name_gfa1,
     :from_orient => :orientation,
     :to => :segment_name_gfa1,
     :to_orient => :orientation,
     :overlap => :alignment_gfa1,
     :MQ => :i,
     :NM => :i,
     :RC => :i,
     :FC => :i,
     :KC => :i,
  }
  NAME_FIELD = nil
  STORAGE_KEY = nil
  REFERENCE_FIELDS = [:from, :to]
  BACKREFERENCE_RELATED_FIELDS = [:to_orient, :from_orient, :overlap]
  DEPENDENT_LINES = [:paths]
  OTHER_REFERENCES = []

  apply_definitions

end

require_relative "common/alignment_type"
require_relative "common/from_to"
require_relative "gfa1/to_gfa2"
require_relative "gfa1/references"
require_relative "gfa1/oriented_segments"
require_relative "gfa1/alignment_type"
require_relative "gfa1/other"
require_relative "link/canonical"
require_relative "link/complement"
require_relative "link/equivalence"
require_relative "link/references"
require_relative "link/to_gfa2"

class RGFA::Line::Edge::Link
  include RGFA::Line::Edge::Common::FromTo
  include RGFA::Line::Edge::Common::AlignmentType
  include RGFA::Line::Edge::GFA1::ToGFA2
  include RGFA::Line::Edge::GFA1::References
  include RGFA::Line::Edge::GFA1::OrientedSegments
  include RGFA::Line::Edge::GFA1::AlignmentType
  include RGFA::Line::Edge::GFA1::Other
  include RGFA::Line::Edge::Link::Canonical
  include RGFA::Line::Edge::Link::Complement
  include RGFA::Line::Edge::Link::Equivalence
  include RGFA::Line::Edge::Link::References
  include RGFA::Line::Edge::Link::ToGFA2
end

