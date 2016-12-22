module RGFA::Line::Edge::GFA2::AlignmentType

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
    elsif sid1.orient == sid2.orient
      if (st1 == :pfx and st2 == :sfx) or (st1 == :sfx and st2 == :pfx)
        return :L
      else
        return :I
      end
    else
      if (st1 == :pfx and st2 == :pfx) or (st1 == :sfx and st2 == :sfx)
        return :L
      else
        return :I
      end
    end
  end

  # Analyze the begin and end position and determine if the substring is
  #   the whole string, or a (possibly empty) other substring, ie a prefix,
  #   a suffix, or an internal alignment
  # @param begpos [RGFA::LastPos,Integer]
  #    begin position of the substring on a segment
  # @param endpos [RGFA::LastPos,Integer]
  #    end position of the substring on a segment
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
    if begpos.first?
      if endpos.first?
        return :pfx, true
      elsif endpos.last?
        return :whole, false
      else
        return :pfx, false
      end
    elsif begpos.last?
      if !endpos.last?
        raise RGFA::FormatError,
          "Line: #{self.to_s}\n"+
          "Wrong use of $ marker\n"+
          "#{endpos.value} >= #{begpos.value}$"
      end
      return :sfx, true
    else
      if endpos.last?
        return :sfx, false
      else
        return :internal, begpos.value == endpos.value
      end
    end
  end

end
