# Sets the reference to the segment in fragments, when they are connected
# to a RGFA instance; creates a virtual segment, if the segment has not
# been found yet
module RGFA::Line::Fragment::References

  private

  def initialize_references
    s = @rgfa.segment(get(:sid))
    if s.nil?
      raise RGFA::NotFoundError if @rgfa.segments_first_order
      s = RGFA::Line::Segment::GFA2.new({:sid => get(:sid),
                                         :slen => 1,
                                         :sequence => "*"},
                                         version: :gfa2,
                                         virtual: true)
      s.connect(@rgfa)
    end
    set_existing_field(:sid, s, set_reference: true)
    s.add_reference(self, :fragments)
  end

end
