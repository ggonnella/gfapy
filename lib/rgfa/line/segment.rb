#
# Parent class for classes representing S lines
# RGFA::Line::Segment::GFA1 and
# RGFA::Line::Segment::GFA2
#
class RGFA::Line::Segment < RGFA::Line
end

require_relative "segment/gfa1.rb"
require_relative "segment/gfa2.rb"
require_relative "segment/factory.rb"
