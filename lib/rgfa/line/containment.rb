require_relative "../segment_references.rb"

# A containment line of a RGFA file
class RGFA::Line::Containment < RGFA::Line

  RECORD_TYPE = :C
  REQFIELDS = [:from, :from_orient, :to, :to_orient, :pos, :overlap]
  PREDEFINED_OPTFIELDS = [:MQ, :NM]
  DATATYPE = {
     :from => :lbl,
     :from_orient => :orn,
     :to => :lbl,
     :to_orient => :orn,
     :pos => :pos,
     :overlap => :cig,
     :MQ => :i,
     :NM => :i,
  }

  include RGFA::SegmentReferences

end
