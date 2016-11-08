# A segment line of a RGFA file
class RGFA::Line::SegmentGFA1 < RGFA::Line

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
    :UR => :Z
  }
  FIELD_ALIAS = { :sid => :name, :id => :name }
  REFERENCE_FIELDS = []
  DEPENDENT_REFERENCES = [:dovetails_L, :dovetails_R, :gaps_L, :gaps_R,
                          :contained, :containers, :fragments,
                          :unordered_groups, :ordered_groups]
                          # some are always empty but still here
                          # so that the interface remains compatible with GFA2
  NONDEPENDENT_REFERENCES = [:paths]

  define_field_methods!

  alias_method :to_sym, :name

end

require_relative "segment/gfa1_to_gfa2"
require_relative "segment/length_gfa1"
require_relative "segment/coverage"
require_relative "segment/references"
require_relative "segment/writer_wo_sequence"

class RGFA::Line::SegmentGFA1
  include RGFA::Line::Segment::GFA1ToGFA2
  include RGFA::Line::Segment::LengthGFA1
  include RGFA::Line::Segment::Coverage
  include RGFA::Line::Segment::References
  include RGFA::Line::Segment::WriterWoSequence
end
