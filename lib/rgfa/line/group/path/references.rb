module RGFA::Line::Group::Path::References

  private

  # Computes the list of links which are required to support
  # the path
  # @return
  #   [Array<[RGFA::OrientedLine, RGFA::OrientedLine, RGFA::Alignment::CIGAR]>]
  #   an array, which elements are 3-tuples (from oriented segment,
  #   to oriented segment, cigar)
  # @api private
  def compute_required_links
    has_undef_overlaps = undef_overlaps?
    retval = []
    is_circular = self.circular?
    segment_names.size.times do |i|
      j = i+1
      if j == self.segment_names.size
        is_circular ? j = 0 : break
      end
      cigar = has_undef_overlaps ?
        RGFA::Alignment::Placeholder.new : self.overlaps[i]
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

  def initialize_references
    initialize_links
    initialize_segments
  end

  def initialize_links
    refs[:links] = []
    compute_required_links.each do |from,to,cigar|
      l = nil
      orient = :+
      if @rgfa.segment(from.line) and @rgfa.segment(to.line)
        l = @rgfa.search_link(from, to, cigar)
        if !l.nil? and l.compatible_complement?(from, to, cigar)
          orient = :-
        end
      end
      if l.nil?
        if @rgfa.segments_first_order
          raise RGFA::NotFoundError, "Path: #{self}\n"+
          "requires a non-existing link:\n"+
          "from=#{from} to=#{to} cigar=#{cigar}"
        end
        l = RGFA::Line::Edge::Link.new({:from => from.line,
                                  :from_orient => from.orient,
                                  :to => to.line,
                                  :to_orient => to.orient,
                                  :overlap => cigar},
                                  virtual: true,
                                  version: :gfa1)
        l.connect(@rgfa)
      end
      @refs[:links] << OL[l,orient]
      l.add_reference(self, :paths)
    end
  end

  def initialize_segments
    segment_names.each do |sn_with_o|
      s = @rgfa.segment(sn_with_o.line)
      sn_with_o.line = s
      s.add_reference(self, :paths)
    end
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
