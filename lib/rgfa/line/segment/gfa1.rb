require_relative "common_definitions"

# A segment line of a RGFA file
class RGFA::Line::Segment::GFA1 < RGFA::Line::Segment

  include RGFA::Line::Segment::CommonDefinitions
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

  define_field_methods!

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
