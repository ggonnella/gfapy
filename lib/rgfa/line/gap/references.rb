module RGFA::Line::Gap::References

  private

  def initialize_references
    [1,2].each do |snum|
      sid = :"sid#{snum}"
      orient = get(sid).orient
      linesymbol = get(sid).line
      s = @rgfa.segment(linesymbol)
      if s.nil?
        raise RGFA::NotFoundError if @rgfa.segments_first_order
        s = RGFA::Line::Segment::GFA2.new({:sid => linesymbol,
                                           :slen => 1,
                                           :sequence => "*"},
                                           version: :gfa2,
                                           virtual: true)
        s.connect(@rgfa)
      end
      set_existing_field(sid, OL[s,orient], set_reference: true)
      s.add_reference(self, refkey_for_s(snum))
    end
  end

  def refkey_for_s(snum)
    case [sid1.orient, sid2.orient]
    when [:+, :+]
      return (snum == 1) ? :gaps_R : :gaps_L
    when [:+, :-]
      return :gaps_R
    when [:-, :+]
      return :gaps_L
    when [:-, :-]
      return (snum == 1) ? :gaps_L : :gaps_R
    else
      raise RGFA::AssertionError, "Bug found, please report\n"+
        "snum: #{snum}"
    end
  end

  def import_field_references(previous)
    [:sid1, :sid2].each do |sid|
      orient = get(sid).orient
      linesymbol = get(sid).line
      set_existing_field(sid, OL[@rgfa.segment(linesymbol),orient],
                         set_reference: true)
    end
  end

end
