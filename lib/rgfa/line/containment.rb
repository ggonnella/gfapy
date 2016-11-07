# A containment line of a RGFA file
class RGFA::Line::Containment < RGFA::Line

  RECORD_TYPE = :C
  POSFIELDS = [:from, :from_orient, :to, :to_orient, :pos, :overlap]
  REFERENCE_FIELDS = [:from, :from_orient, :to, :to_orient]
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

  define_field_methods!
end

require_relative "connection/alignment_type"
require_relative "connection/ends_gfa1"
require_relative "connection/gfa1_to_gfa2"
require_relative "containment/canonical.rb"
require_relative "containment/references.rb"
require_relative "containment/pos.rb"

class RGFA::Line::Containment
  include RGFA::Line::Connection::EndsGFA1
  include RGFA::Line::Connection::GFA1ToGFA2
  include RGFA::Line::Connection::AlignmentType
  include RGFA::Line::Containment::Canonical
  include RGFA::Line::Containment::References
  include RGFA::Line::Containment::Pos
end
