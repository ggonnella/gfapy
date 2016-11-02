require_relative "../connection"

module RGFA::Line::Connection::GFA2ToGFA1

  # @return [Array<String>] an array of fields of the equivalent line
  #   in GFA1, if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to_gfa1_a
    case alignment_type
    when :I
      raise RGFA::ValueError, "Line: #{self.to_s}\n"+
        "Internal alignment, cannot be represented in GFA1"
    else
      a = [alignment_type]
      if beg1.first
        a += [field_to_s(:sid2), field_to_s(:or2), field_to_s(:sid1), "+"]
        if alignment_type == :C
          a << field_to_s(:beg2)
        end
      else
        a += [field_to_s(:sid1), "+", field_to_s(:sid2), field_to_s(:or2)]
        if alignment_type == :C
          a << field_to_s(:beg1)
        end
      end
    end
    a << overlap.to_s
    if eid != "*" and eid != RGFA::Placeholder
      a << eid.to_gfa_field(datatype: :Z, fieldname: :ID)
    end
    tagnames.each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

  # Value of the alignment field if +sid1+ and +sid2+ are switched
  # @return [RGFA::Placeholder, RGFA::CIGAR] if the alignment is a cigar string,
  #   the complement cigar string is computed; otherwise a placeholder is
  #   returned, as the complement of a trace can only be computed by computing
  #   the alignment
  def complement_alignment
    alignment.kind_of?(RGFA::CIGAR) ?
      alignment.complement :
      RGFA::Placeholder.new
  end

  # @return [RGFA::Placeholder, RGFA::CIGAR] value of the GFA1 +overlap+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def overlap
    if internal?
      raise RGFA::ValueError,
        "Line: #{self.to_s}\n"+
        "Internal alignment, overlap is not defined"
    end
    case alignment
    when RGFA::Placeholder, RGFA::Trace
      RGFA::Placeholder.new
    when RGFA::CIGAR
      if beg1.first
        alignment
      else
        complement_alignment
      end
    else
      raise # this should not happen
    end
  end

  # @return [RGFA::Placeholder, RGFA::CIGAR] complement of the value of the
  #   GFA1 +overlap+ field, if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def complement_overlap
    overlap.complement
  end

  # @return [Symbol, RGFA::Line::SegmentGFA2] value of the GFA1 +from+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def from
    if internal?
      raise RGFA::ValueError,
        "Line: #{self.to_s}\n"+
        "Internal alignment, from is not defined"
    end
    beg1.first ? sid2 : sid1
  end

  # @return [:+, :-] value of the GFA1 +from_orient+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def from_orient
    if internal?
      raise RGFA::ValueError,
        "Line: #{self.to_s}\n"+
        "Internal alignment, from_orient is not defined"
    end
    beg1.first ? or2 : :"+"
  end

  # @return [Symbol, RGFA::Line::SegmentGFA2] value of the GFA1 +to+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to
    if internal?
      raise RGFA::ValueError,
        "Line: #{self.to_s}\n"+
        "Internal alignment, to is not defined"
    end
    beg1.first ? sid1 : sid2
  end

  # @return [:+, :-] value of the GFA1 +to_orient+ field,
  #   if the edge is a link or containment
  # @raise [RGFA::ValueError] if the edge is internal
  def to_orient
    if internal?
      raise RGFA::ValueError,
        "Line: #{self.to_s}\n"+
        "Internal alignment, to_orient is not defined"
    end
    beg1.first ? :"+" : or2
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
      beg1.first ? beg2 : beg1
    end
  end

end