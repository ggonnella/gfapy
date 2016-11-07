# A link connects two segments, or a segment to itself.
class RGFA::Line::Link < RGFA::Line

  RECORD_TYPE = :L
  POSFIELDS = [:from, :from_orient, :to, :to_orient, :overlap]
  REFERENCE_FIELDS = [:from, :from_orient, :to, :to_orient, :overlap]
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

  define_field_methods!

end

require_relative "connection/alignment_type"
require_relative "connection/ends_gfa1"
require_relative "connection/gfa1_to_gfa2"
require_relative "link/canonical"
require_relative "link/complement"
require_relative "link/equivalence"
require_relative "link/references"

class RGFA::Line::Link
  include RGFA::Line::Connection::EndsGFA1
  include RGFA::Line::Connection::GFA1ToGFA2
  include RGFA::Line::Connection::AlignmentType
  include RGFA::Line::Link::Canonical
  include RGFA::Line::Link::Complement
  include RGFA::Line::Link::Equivalence
  include RGFA::Line::Link::References
end

