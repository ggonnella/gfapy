# A containment line of a RGFA file
class RGFA::Line::Containment < RGFA::Line

  RECORD_TYPE = :C
  POSFIELDS = [:from, :from_orient, :to, :to_orient, :pos, :overlap]
  FIELD_ALIAS = {}
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

  # @return [RGFA::OrientedSegment] the oriented segment represented by the
  #   from/from_orient fields
  def oriented_from
    [from, from_orient].to_oriented_segment
  end

  # @return [RGFA::OrientedSegment] the oriented segment represented by the
  #   to/to_orient fields
  def oriented_to
    [to, to_orient].to_oriented_segment
  end

  # The from segment name, in both cases where from is a segment name (Symbol)
  # or a segment (RGFA::Line::SegmentGFA1)
  # @return [Symbol]
  def from_name
    from.to_sym
  end

  # The to segment name, in both cases where to is a segment name (Symbol)
  # or a segment (RGFA::Line::SegmentGFA1)
  # @return [Symbol]
  def to_name
    to.to_sym
  end

  # @return [Integer,nil] the rightmost 0-based coordinate of the contained
  #   sequence in the container; nil if the overlap is unspecified
  def rpos
    return nil if overlap.empty?
    rpos = pos
    overlap.each do |op|
      if [:M, :D].include?(op.code)
        rpos += op.len
      end
    end
    return rpos
  end

  # Returns true if the containment is canonical, false otherwise
  #
  # == Definition of canonical containment
  #
  # A containment is canonical if the from orientation is +
  #
  # === Details
  #
  # Each containment has an equivalent complement containment.
  # Consider a containment of B (length:8) in A (length:100) at position 9 of A
  # with a cigar 1M1I2M3D4M (i.e. rpos = 19).
  #
  #   A+ B+ 1M1I2M3D4M 9 == A- B- 4M3D2M1I1M 80
  #   A+ B- 1M1I2M3D4M 9 == A- B+ 4M3D2M1I1M 80
  #   A- B+ 1M1I2M3D4M 9 == A+ B- 4M3D2M1I1M 80
  #   A- B- 1M1I2M3D4M 9 == A+ B+ 4M3D2M1I1M 80
  #
  # Pos in the complement is equal to the length of A minus the right pos
  # of B before reversing.
  #
  # We require here that A != B as A == B makes no sense for containments.
  # Thus it is always possible to express the containment using a positive
  # from orientation.
  #
  # For this reason the canon is simply defined as + from orientation.
  #
  # @return [Boolean]
  #
  def canonical?
    from_orient == :+
  end

end
