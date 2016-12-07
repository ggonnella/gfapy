# An edge line of a GFA2 file
class RGFA::Line::Edge::GFA2 < RGFA::Line::Edge

  RECORD_TYPE = :E
  POSFIELDS = [:eid, :sid1, :sid2, :beg1, :end1, :beg2, :end2, :alignment]
  PREDEFINED_TAGS = []
  DATATYPE = {
    :eid => :optional_identifier_gfa2,
    :sid1 => :oriented_identifier_gfa2,
    :sid2 => :oriented_identifier_gfa2,
    :beg1 => :position_gfa2,
    :end1 => :position_gfa2,
    :beg2 => :position_gfa2,
    :end2 => :position_gfa2,
    :alignment => :alignment_gfa2,
  }
  NAME_FIELD = :eid
  STORAGE_KEY = :name
  FIELD_ALIAS = {}
  REFERENCE_FIELDS = [:sid1, :sid2]
  BACKREFERENCE_RELATED_FIELDS = [:beg1, :end1, :beg2, :end2]
  DEPENDENT_LINES = [:paths, :sets]
  OTHER_REFERENCES = []

  apply_definitions

  alias_method :to_sym, :eid

end

require_relative "common/from_to"
require_relative "common/alignment_type"
require_relative "gfa2/to_gfa1"
require_relative "gfa2/alignment_type"
require_relative "gfa2/references"
require_relative "gfa2/other"

class RGFA::Line::Edge::GFA2
  include RGFA::Line::Edge::Common::FromTo
  include RGFA::Line::Edge::Common::AlignmentType
  include RGFA::Line::Edge::GFA2::AlignmentType
  include RGFA::Line::Edge::GFA2::ToGFA1
  include RGFA::Line::Edge::GFA2::References
  include RGFA::Line::Edge::GFA2::Other
end
