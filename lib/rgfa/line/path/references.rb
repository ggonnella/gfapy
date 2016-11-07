module RGFA::Line::Path::References

  # The links to which the path refers; it can be an empty array
  # (e.g. from a line which is not embedded in a graph);
  # the boolean is true if the equivalent reverse link is used.
  # @return [Array<RGFA::Line::Link, Boolean>]
  def links
    @links ||= []
    @links
  end

  # computes the list of links which are required to support
  # the path
  # @return [Array<[RGFA::OrientedSegment, RGFA::OrientedSegment, RGFA::CIGAR]>]
  #   an array, which elements are 3-tuples (from oriented segment,
  #   to oriented segment, cigar)
  # @api private
  def required_links
    has_undef_overlaps = undef_overlaps?
    retval = []
    segment_names.size.times do |i|
      j = i+1
      if j == self.segment_names.size
        circular? ? j = 0 : break
      end
      cigar = has_undef_overlaps ? RGFA::Placeholder.new : self.overlaps[i]
      retval << [self.segment_names[i], self.segment_names[j], cigar]
    end
    retval
  end

  private

  # Are the overlaps a single "*"? This is a compact representation of
  # a linear path where all CIGARs are "*"
  # @return [Boolean]
  # @api private
  def undef_overlaps?
    overlaps.size == 1 and overlaps[0].empty?
  end

  # @note: called by RGFA::Line::Link#merge_virtual
  def update_link_reference(old_link, new_link)
    l = @links.delete(old_link)
    if l.nil?
      raise RGFA::NotFoundError,
        "\nLink to delete: #{old_link.map(&:to_s)}\n"+
        "Links: #{links.map{|ln,dir|[ln.to_s,dir]}}"
    end
    @links << new_link
  end

  # @note: called by RGFA::Line::Segment#merge_virtual
  def update_segment_references(old_segment, new_segment)
    found_at_least_once = false
    segment_names.each do |s_o|
      if s_o[0] == old_segment
        found_at_least_once = true
        s_o[0] = new_segment
      end
    end
    if !found_at_least_once
      raise RGFA::NotFoundError,
        "\nSegment to delete: #{old_segment}\n"+
        "Segments: #{segment_names.map{|s,o|[s.name,o]}}"
    end
  end
  def create_references
    connect_links
    connect_segments
  end

  def remove_references
    disconnect_links
    disconnect_segments
  end

  def connect_links
    @links = []
    required_links.each do |from,to,cigar|
      l = nil
      if @rgfa.segment(from.segment) and @rgfa.segment(to.segment)
        l = rgfa.search_link(from, to, cigar)
      end
      if l.nil?
        if @rgfa.segments_first_order
          raise RGFA::NotFoundError, "Path: #{self}\n"+
          "requires a non-existing link:\n"+
          "#{l}"
        end
        l = RGFA::Line::Link.new({:from => from.segment,
                                  :from_orient => from.orient,
                                  :to => to.segment,
                                  :to_orient => to.orient,
                                  :overlap => cigar},
                                  virtual: true,
                                  version: :"1.0")
        l.connect(@rgfa)
      end
      direct = l.compatible_direct?(from, to, cigar)
      @links << [l, direct]
      l.paths << [self, direct]
    end
  end

  def connect_segments
    segment_names.each do |sn_with_o|
      sn_with_o[0] = rgfa.segment(sn_with_o[0])
      sn_with_o[0].paths[sn_with_o[1]] << self
    end
  end

  def disconnect_links
    @links.each {|l, dir| l.paths.delete([self, dir])}
  end

  def disconnect_segments
    segment_names.each {|s, o| s.paths[o].delete(self)}
  end

end
