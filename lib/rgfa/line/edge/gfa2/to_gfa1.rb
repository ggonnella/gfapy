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

  # @return [RGFA::Alignment::Placeholder, RGFA::Alignment::CIGAR]
  #   value of the GFA1 +overlap+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def overlap
    check_not_internal(:overlap)
    beg1.first? ? alignment.complement : alignment
  end

  def oriented_from
    if beg1.first?
      (beg2.first? and end2.last?) ? sid1 : sid2
    else
      sid1
    end
  end

  def oriented_to
    if beg1.first?
      (beg2.first? and end2.last?) ? sid2 : sid1
    else
      sid2
    end
  end

  # @return [Symbol, RGFA::Line::Segment::GFA2] value of the GFA1 +from+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def from
    check_not_internal(:from)
    oriented_from.line
  end

  # Set the field which will be returned by calling from
  # @param value [Symbol, RGFA::Line::Segment::GFA2]
  # @return [nil]
  def from=(value)
    check_not_internal(:from)
    oriented_from.line = value
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
    oriented_to.line
  end

  # Set the field which will be returned by calling to
  # @param value [Symbol, RGFA::Line::Segment::GFA2]
  # @return [nil]
  def to=(value)
    check_not_internal(:to)
    oriented_to.line = value
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
      if beg1.first?
        (beg2.first? and end2.last?) ? beg1 : beg2
      else
        beg1
      end
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
