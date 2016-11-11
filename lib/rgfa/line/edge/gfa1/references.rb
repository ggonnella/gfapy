RGFA::Line::Edge::GFA1 ||= Module.new

module RGFA::Line::Edge::GFA1::References

  private

  def initialize_references
    [:from, :to].each do |dir|
      s = @rgfa.segment(get(dir))
      if s.nil?
        raise RGFA::NotFoundError if @rgfa.segments_first_order
        s = RGFA::Line::Segment::GFA1.new({:name => get(dir),
                                         :sequence => "*"},
                                         version: :"1.0",
                                         virtual: true)
        s.connect(@rgfa)
      end
      set_existing_field(dir, s, set_reference: true)
      if self.record_type == :L
        et = send(:"#{dir}_end").end_type
        key = :"dovetails_#{et}"
      else
        key = (dir == :from) ? :contained : :containers
      end
      s.add_reference(self, key)
    end
  end

  def import_field_references(previous)
    [:from, :to].each do |dir|
      set_existing_field(dir, @rgfa.segment(get(dir)),
                         set_reference: true)
    end
  end

  def backreference_keys(ref, key_in_ref)
    case ref.record_type
    when :P
      [:paths]
    when :S
      [:from, :to]
    else
      []
    end
  end

end
