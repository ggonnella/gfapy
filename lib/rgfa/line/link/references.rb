module RGFA::Line::Link::References

  # Paths which contain the link (or its complement).
  #
  # @return [Array<Array(RGFA::Line::Path, Boolean)>, []] If connected to
  #   a RGFA instance, array of path/bool pairs (bool: +true+ the link
  #   is used; +false+ its complement). If not connected: empty array.
  def paths
    @paths ||= []
  end

  private

  def create_references
    connect_segments
  end

  def remove_references
    disconnect_paths
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
      s.links[dir][orient] << self
      set_existing_field(dir, s, set_reference: true)
    end
  end

  def disconnect_segments
    [:from, :to].each do |dir|
      s = get(dir)
      orient = get(:"#{dir}_orient")
      s.links[dir][orient].delete(self)
      set_existing_field(dir, s.to_sym, set_reference: true)
    end
  end
  protected :disconnect_segments

  def disconnect_paths
    paths.each {|pt, orient| @rgfa.path(pt).disconnect!}
    @paths = [] # TODO notify the paths
                # that I am disconnecting;
                # maybe this could a flag in the path
                # "not supported by links"
  end

  def merge_virtual(previous)
    merge_virtual_process_paths(previous)
    merge_virtual_process_segments(previous)
  end

  def merge_virtual_process_paths(previous)
    @paths ||= []
    compl = complement_ends?(previous)
    previous.paths.each do |path, previous_dir|
      this_dir = compl ? (!previous_dir) : previous_dir
      @paths << [path, this_dir]
      path.send(:update_link_reference,
                [previous, previous_dir],
                [self, this_dir])
    end
  end

  def merge_virtual_process_segments(previous)
    previous.disconnect_segments
  end

  def process_line_not_unique(previous)
    if previous.complement?
      # do nothing
    else
      super
    end
  end

end
