module RGFA::Line::Edge::GFA2::ToGFA1

  # @return [Array<String>] an array of fields of the equivalent line
  #   in GFA1, if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to_gfa1_a
    check_not_internal("GFA1 representation")
    a = [alignment_type]
    a << oriented_from.name
    a << oriented_from.orient
    a << oriented_to.name
    a << oriented_to.orient
    if alignment_type == :C
      a << pos.to_s
    end
    a << overlap.to_s
    if !eid.placeholder?
      a << eid.to_gfa_field(datatype: :Z, fieldname: :ID)
    end
    tagnames.each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

  # Value of the alignment field if +sid1+ and +sid2+ are switched
  # @return [RGFA::Alignment::Placeholder, RGFA::Alignment::CIGAR] if the alignment is a cigar string,
  #   the complement cigar string is computed; otherwise a placeholder is
  #   returned, as the complement of a trace can only be computed by computing
  #   the alignment
  def complement_alignment
    alignment.complement
  end

  # @return [RGFA::Alignment::Placeholder, RGFA::Alignment::CIGAR]
  #   value of the GFA1 +overlap+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def overlap
    check_not_internal(:overlap)
    beg1.first? ? alignment.complement : alignment
  end

  # @return [RGFA::Alignment::Placeholder, RGFA::Alignment::CIGAR]
  #   complement of the value of the
  #   GFA1 +overlap+ field, if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def complement_overlap
    overlap.complement
  end

  def oriented_from
    beg1.first? ? sid2 : sid1
  end

  def oriented_to
    beg1.first? ? sid1 : sid2
  end

  # @return [Symbol, RGFA::Line::Segment::GFA2] value of the GFA1 +from+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def from
    check_not_internal(:from)
    oriented_from.segment
  end

  # Set the field which will be returned by calling from
  # @param value [Symbol, RGFA::Line::Segment::GFA2]
  # @return [nil]
  def from=(value)
    check_not_internal(:from)
    oriented_from.segment = value
  end

  # @return [:+, :-] value of the GFA1 +from_orient+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def from_orient
    check_not_internal(:from_orient)
    oriented_from.orient
  end

  # @return [Symbol, RGFA::Line::Segment::GFA2] value of the GFA1 +to+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to
    check_not_internal(:to)
    oriented_to.segment
  end

  # Set the field which will be returned by calling to
  # @param value [Symbol, RGFA::Line::Segment::GFA2]
  # @return [nil]
  def to=(value)
    check_not_internal(:to)
    oriented_to.segment = value
  end

  # @return [:+, :-] value of the GFA1 +to_orient+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to_orient
    check_not_internal(:to_orient)
    oriented_to.orient
  end

  # @return [Integer] value of the GFA1 +pos+ field,
  #   if the edge is a containment
  # @raise [RGFA::ValueError] if the edge is not
  #   a containment
  def pos
    case alignment_type
    when :I
      raise RGFA::ValueError, "Line: #{self.to_s}\n"+
        "Internal alignment, pos is not defined"
    when :L
      raise RGFA::ValueError, "Line: #{self.to_s}\n"+
        "Dovetail alignment, pos is not defined"
    when :C
      beg1.first? ? beg2 : beg1
    end
  end

  private

  def check_not_internal(fn)
    if internal?
      raise RGFA::ValueError,
        "Line: #{self.to_s}\n"+
        "Internal alignment, #{fn} is not defined"
    end
  end

end
