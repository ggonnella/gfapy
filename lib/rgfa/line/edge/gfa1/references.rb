RGFA::Line::Edge::GFA1 ||= Module.new

module RGFA::Line::Edge::GFA1::References

  private

  def initialize_references
    [:from, :to].each do |dir|
      s = @rgfa.segment(get(:"#{dir}_segment"))
      if s.nil?
        raise RGFA::NotFoundError if @rgfa.segments_first_order
        s = RGFA::Line::Segment::GFA1.new({:name => get(dir),
                                         :sequence => "*"},
                                         version: :gfa1,
                                         virtual: true)
        s.connect(@rgfa)
      end
      set_existing_field(:"#{dir}_segment", s, set_reference: true)
      if self.record_type == :L
        et = send(:"#{dir}_end").end_type
        key = :"dovetails_#{et}"
      else
        key = (dir == :from) ?
          :edges_to_contained :
          :edges_to_containers
      end
      s.add_reference(self, key)
    end
  end

  def import_field_references(previous)
    [:from_segment, :to_segment].each do |dir|
      set_existing_field(dir, @rgfa.segment(get(dir)), set_reference: true)
    end
  end

  def backreference_keys(ref, key_in_ref)
    case ref.record_type
    when :P
      [:paths]
    when :S
      [:from_segment, :to_segment]
    else
      []
    end
  end

end
