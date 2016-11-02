# An edge line of a GFA2 file
class RGFA::Line::Edge < RGFA::Line

  RECORD_TYPE = :E
  POSFIELDS = [:eid, :sid1, :or2, :sid2, :beg1,
               :end1, :beg2, :end2, :alignment]
  PREDEFINED_TAGS = []
  DATATYPE = {
    :eid => :optional_identifier_gfa2,
    :sid1 => :identifier_gfa2,
    :or2 => :orientation,
    :sid2 => :identifier_gfa2,
    :beg1 => :position_gfa2,
    :end1 => :position_gfa2,
    :beg2 => :position_gfa2,
    :end2 => :position_gfa2,
    :alignment => :alignment_gfa2,
  }
  FIELD_ALIAS = { :id => :eid }

  define_field_methods!

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

  # @return [Boolean] does the edge represent an internal
  #   overlap (not representable in GFA1)?
  def internal?
    alignment_type == :I
  end

  # @return [Boolean] does the edge represent a containment
  #   (equivalent to a containment line in GFA1)?
  def containment?
    alignment_type == :C
  end

  # @return [Boolean] does the edge represent a dovetail
  #   overlap (equivalent to a link line in GFA1)?
  def link?
    alignment_type == :L
  end

  # @return [:C, :L, :I] +:C+ if containment, +:L+ if link,
  #   +:I+ (internal) if any other local alignment
  def alignment_type
    st1 = substring_type(beg1, end1)[0]
    st2 = substring_type(beg2, end2)[0]
    alignment_type_for_substring_types(st1, st2)
  end

  private

  # @param st1 [substring_type] value for sid1
  # @param st2 [substring_type] value for sid2
  # @return [:C, :L, :I] +:C+ if containment, +:L+ if link,
  #   +:I+ (internal) if any other local alignment
  def alignment_type_for_substring_types(st1, st2)
    if st1 == :whole or st2 == :whole
      return :C
    elsif or2 == :+
      if (st1 == :pfx and st2 == :sfx) or (st1 == :sfx and st2 == :pfx)
        return :L
      else
        return :I
      end
    else
      if (st1 == :pfx or st2 == :sfx) and (st1 == st2)
        return :L
      else
        return :I
      end
    end
  end

  # Analyze the begin and end position and determine if the substring is
  #   the whole string, or a (possibly empty) other substring, ie a prefix,
  #   a suffix, or an internal alignment
  # @param begpos [RGFA::Position] begin position of the substring on a segment
  # @param endpos [RGFA::Position] end position of the substring on a segment
  # @return [Array<substring_type, Boolean>] The first value is the
  #   substring type, which a symbol (one of: +:pfx+, +:sfx+, +:whole+,
  #   +:internal+). Thereby, with pfx or sfx is meant a prefix or suffix which
  #   is not the complete string. With internal is meant a substring which
  #   starts after the first position and ends before the last position. The
  #   second value is a boolean, +true+ if the substring is empty, +false+
  #   otherwise.
  def substring_type(begpos, endpos)
    if begpos.value > endpos.value
      raise RGFA::ValueError,
        "Line: #{self.to_s}\n"+
        "begin > end: #{begpos.value}$ > #{endpos.value}"
    end
    if begpos.first
      if endpos.first
        return :pfx, true
      elsif endpos.last
        return :whole, false
      else
        return :pfx, false
      end
    elsif begpos.last
      if !endpos.last
        raise RGFA::FormatError,
          "Line: #{self.to_s}\n"+
          "Wrong use of $ marker\n"+
          "#{endpos.value} >= #{begpos.value}$"
      end
      return :sfx, true
    else
      if endpos.last
        return :sfx, false
      else
        return :internal, begpos.value == endpos.value
      end
    end
  end

end
