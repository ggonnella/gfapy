module RGFA::Line::Edge::GFA2::ToGFA1

  # @return [Array<String>] an array of fields of the equivalent line
  #   in GFA1, if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to_gfa1_a
    at = alignment_type()
    if at == :internal
      raise RGFA::ValueError,
        "Internal overlap, cannot convert to GFA1\n#{self}"
    end
    a = [at]
    (sid1_from? ? [:sid1, :sid2] : [:sid2, :sid1]).each do |sid|
      ol = get(sid)
      a << ol.name.to_s
      a << ol.orient.to_s
    end
    if at == :C
      a << pos.to_s
    end
    a << overlap.to_s
    if !eid.placeholder?
      a << eid.to_gfa_tag(:id, datatype: :Z)
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
    sid1_from? ? alignment : alignment.complement
  end

  # @return [RGFA::OrientedLine] value of the GFA1 +from+ and +from_orient+
  #   fields, if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def oriented_from
    sid1_from? ? sid1 : sid2
  end

  # @return [RGFA::OrientedLine] value of the GFA1 +to+ and +to_orient+
  #   fields, if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def oriented_to
    sid1_from? ? sid2 : sid1
  end

  # @return [Symbol, RGFA::Line::Segment::GFA2] value of the GFA1 +from+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def from
    oriented_from.line
  end

  # Set the line of the field which will be returned by calling from
  # @param value [Symbol, RGFA::Line::Segment::GFA2]
  # @return [nil]
  def from=(value)
    oriented_from.line = value
  end

  # @return [:+, :-] value of the GFA1 +from_orient+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def from_orient
    oriented_from.orient
  end

  # Set the orientation of the field which will be returned by calling from
  # @param value [:+,:-]
  # @return [nil]
  def from_orient=(value)
    oriented_from.orient = value
  end

  # @return [Symbol, RGFA::Line::Segment::GFA2] value of the GFA1 +to+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to
    oriented_to.line
  end

  # Set the line of the field which will be returned by calling to
  # @param value [Symbol, RGFA::Line::Segment::GFA2]
  # @return [nil]
  def to=(value)
    oriented_to.line = value
  end

  # @return [:+, :-] value of the GFA1 +to_orient+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to_orient
    oriented_to.orient
  end

  # Set the orientation of the field which will be returned by calling to
  # @param value [:+,:-]
  # @return [nil]
  def to_orient=(value)
    oriented_to.orient = value
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

  # Role of a segment in an overlap, given coordinates and orientation.
  # @returns [Symbol] :pfx, :sfx, :contained, :other
  def segment_role(begpos, endpos, orient)
    if begpos.first?
      if endpos.last?
        return :contained
      else
        return orient == :+ ? :pfx : :sfx
      end
    else
      if endpos.last?
        return orient == :+ ? :sfx : :pfx
      else
        return :other
      end
    end
  end

  # @return [Boolean] does the sid1 correspond to from in GFA1?
  def sid1_from?
    sr1 = segment_role(beg1, end1, sid1.orient)
    sr2 = segment_role(beg2, end2, sid2.orient)
    if sr2 == :contained
      return true
    elsif sr1 == :contained
      return false
    elsif sr1 == :sfx and sr2 == :pfx
      return true
    elsif sr2 == :sfx and sr1 == :pfx
      return false
    else
      raise RGFA::ValueError, "Internal overlap, from undefined\n#{self}\n"+
         "Roles: segment1 is #{sr1}; segment2 is #{sr2}"
    end
  end

end
