module RGFA::Line::Containment::References

  private

  def create_references
    connect_segments
  end

  def remove_references
    disconnect_segments
  end

  def connect_segments
    [:from, :to].each do |dir|
      s = @rgfa.segment(get(dir))
      if s.nil?
        raise RGFA::NotFoundError if @rgfa.segments_first_order
        s = RGFA::Line::SegmentGFA1.new({:name => get(dir),
                                         :sequence => "*"},
                                         version: :"1.0",
                                         virtual: true)
        s.connect(@rgfa)
      end
      orient = get(:"#{dir}_orient")
      s.containments[dir][orient] << self
      set_existing_field(dir, s, set_reference: true)
    end
  end

  def disconnect_segments
    [:from, :to].each do |dir|
      s = get(dir)
      orient = get(:"#{dir}_orient")
      s.containments[dir][orient].delete(self)
      set_existing_field(dir, s.to_sym, set_reference: true)
    end
  end
  protected :disconnect_segments

  def merge_virtual(previous)
    merge_virtual_process_segments(previous)
  end

  def merge_virtual_process_segments(previous)
    previous.disconnect_segments
  end

end
