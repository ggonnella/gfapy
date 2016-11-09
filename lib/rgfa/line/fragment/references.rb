module RGFA::Line::Fragment::References

  private

  def initialize_references
    s = @rgfa.segment(get(:sid))
    if s.nil?
      raise RGFA::NotFoundError if @rgfa.segments_first_order
      s = RGFA::Line::Segment::GFA2.new({:sid => get(:sid),
                                         :slen => 1,
                                         :sequence => "*"},
                                         version: :"2.0",
                                         virtual: true)
      s.connect(@rgfa)
    end
    set_existing_field(:sid, s, set_reference: true)
    s.add_reference(self, :fragments)
  end

  def backreference_keys(ref, key_in_ref)
    case ref.record_type
    when :S
      [:sid]
    else
      raise RGFA::RuntimeError,
        "This should not happen"
    end
  end

end
