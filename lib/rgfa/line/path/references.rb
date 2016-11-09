module RGFA::Line::Path::References

  private

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

  # Are the overlaps a single "*"? This is a compact representation of
  # a linear path where all CIGARs are "*"
  # @return [Boolean]
  # @api private
  def undef_overlaps?
    overlaps.size == 1 and overlaps[0].empty?
  end

  def update_reference_in_field(field, oldref, newref)
    case field
    when :segment_names
      segment_names.each {|s_o| s_o[0] = newref if s_o[0] == oldref }
    end
  end

  def initialize_references
    initialize_links
    initialize_segments
  end

  def initialize_links
    refs[:links] = []
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
        l = RGFA::Line::Edge::Link.new({:from => from.segment,
                                  :from_orient => from.orient,
                                  :to => to.segment,
                                  :to_orient => to.orient,
                                  :overlap => cigar},
                                  virtual: true,
                                  version: :"1.0")
        l.connect(@rgfa)
      end
      @refs[:links] << l
      l.add_reference(self, :paths)
    end
  end

  def initialize_segments
    segment_names.each do |sn_with_o|
      s = @rgfa.segment(sn_with_o[0])
      sn_with_o[0] = s
      s.add_reference(self, :paths)
    end
  end

  def disconnect_field_references
    segment_names.each {|s, o| s.update_references(self, nil, :paths)}
  end

  def backreference_keys(ref, key_in_ref)
    case ref.record_type
    when :L
      [:links]
    when :S
      [:segment_names]
    end
  end

end
