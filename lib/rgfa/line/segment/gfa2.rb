require_relative "common_definitions"

# A segment line of a RGFA file
class RGFA::Line::Segment::GFA2 < RGFA::Line

  include RGFA::Line::Segment::CommonDefinitions
  POSFIELDS = [:sid, :slen, :sequence]
  PREDEFINED_TAGS = [:RC, :FC, :KC, :SH, :UR]
  DATATYPE = {
    :sid => :identifier_gfa2,
    :slen => :i,
    :sequence => :sequence_gfa2,
    :RC => :i,
    :FC => :i,
    :KC => :i,
    :SH => :H,
    :UR => :Z,
  }
  FIELD_ALIAS = { :name => :sid, :length => :slen, :LN => :slen }

  define_field_methods!

  alias_method :to_sym, :sid

end

require_relative "gfa2_to_gfa1"
require_relative "coverage"
require_relative "references"
require_relative "writer_wo_sequence"

class RGFA::Line::Segment::GFA2
  include RGFA::Line::Segment::GFA2ToGFA1
  include RGFA::Line::Segment::Coverage
  include RGFA::Line::Segment::References
  include RGFA::Line::Segment::WriterWoSequence
end
