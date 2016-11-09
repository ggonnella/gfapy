module RGFA::Line::Gap::References

  private

  def initialize_references
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
      s.add_reference(self, refkey_for_s(snum))
    end
  end

  def refkey_for_s(snum)
    case [d1, d2]
    when [:">", :">"]
      return (snum == 1) ? :gaps_R : :gaps_L
    when [:">", :"<"]
      return :gaps_R
    when [:"<", :">"]
      return :gaps_L
    when [:"<", :"<"]
      return (snum == 1) ? :gaps_L : :gaps_R
    else
      raise RGFA::RuntimeError,
        "This should never happen"
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
      raise RGFA::RuntimeError,
        "This should not happen"
    end
  end

end
