# Sets the reference to the segments in gaps, when they are connected
# to a RGFA instance; creates virtual segments, if the segments have not
# been found yet.
#
# Computes the key to the reference to the gap in segments (gaps_R or gaps_L)
# depending on the orientations.
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

end
