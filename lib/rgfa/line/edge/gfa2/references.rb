module RGFA::Line::Edge::GFA2::References

  private

  def initialize_references
    st1 = substring_type(beg1, end1)[0]
    st2 = substring_type(beg2, end2)[0]
    [1,2].each do |snum|
      sid = :"sid#{snum}"
      s = @rgfa.segment(get(sid))
      if s.nil?
        raise RGFA::NotFoundError if @rgfa.segments_first_order
        s = RGFA::Line::Segment::GFA2.new({:sid => get(sid),
                                           :slen => 1,
                                           :sequence => "*"},
                                           version: :"2.0",
                                           virtual: true)
        s.connect(@rgfa)
      end
      set_existing_field(sid, s, set_reference: true)
      s.add_reference(self, refkey_for_s(snum, st1, st2))
    end
  end

  def refkey_for_s(snum, st1, st2)
    if st1 == :whole
      return snum == 1 ? :contained : :containers
    elsif st2 == :whole
      return snum == 1 ? :containers : :contained
    elsif or2 == :+
      if (st1 == :pfx and st2 == :sfx)
        return snum == 1 ? :dovetails_L : :dovetails_R
      elsif (st1 == :sfx and st2 == :pfx)
        return snum == 1 ? :dovetails_R : :dovetails_L
      else
        return :internals
      end
    else
      if (st1 == :pfx and st2 == :pfx)
        return :dovetails_L
      elsif (st1 == :sfx and st2 == :sfx)
        return :dovetails_R
      else
        return :internals
      end
    end
  end

  def import_field_references(previous)
    [:sid1, :sid2].each do |sid|
      set_existing_field(sid, @rgfa.segment(get(sid)),
                         set_reference: true)
    end
  end

  def backreference_keys(ref, key_in_ref)
    case ref.record_type
    when :U
      [:unordered_groups]
    when :O
      [:ordered_groups]
    when :S
      [:sid1, :sid2]
    else
      raise RGFA::AssertionError,
        "Bug found, please report\n"+
        "ref: #{ref}\n"+
        "key_in_ref: #{key_in_ref}"
    end
  end

end
