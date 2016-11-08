# A segment line of a RGFA file
class RGFA::Line::SegmentGFA2 < RGFA::Line

  RECORD_TYPE = :S
  POSFIELDS = [:sid, :slen, :sequence]
  REFERENCE_FIELDS = []
  PREDEFINED_TAGS = [:LN, :RC, :FC, :KC, :SH, :UR]
  DATATYPE = {
    :sid => :identifier_gfa2,
    :slen => :i,
    :sequence => :sequence_gfa2,
    :RC => :i,
    :FC => :i,
    :KC => :i,
    :SH => :H,
    :UR => :Z
  }
  FIELD_ALIAS = { :name => :sid, :id => :sid, :length => :slen }
  DEPENDENT_REFERENCES = [:dovetails_L, :dovetails_R, :gaps_L, :gaps_R,
                          :contained, :containers, :fragments,
                          :unordered_groups, :ordered_groups]
  NONDEPENDENT_REFERENCES = [:paths]

  define_field_methods!

  alias_method :to_sym, :sid

end

require_relative "segment/gfa2_to_gfa1"
require_relative "segment/coverage"
require_relative "segment/references"
require_relative "segment/writer_wo_sequence"

class RGFA::Line::SegmentGFA2
  include RGFA::Line::Segment::GFA2ToGFA1
  include RGFA::Line::Segment::Coverage
  include RGFA::Line::Segment::References
  include RGFA::Line::Segment::WriterWoSequence
end
