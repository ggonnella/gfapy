#
# Methods for the RGFA class, which allow to add lines.
#
module RGFA::Lines::Finders

  # @!macro [new] path
  #   Searches the path with name equal to +pt+.
  #   @param pt [String, RGFA::Line::Path] a path or path name
  #   @return [RGFA::Line::Path] if a path is found
  # @return [nil] if no such path exists in the RGFA instance
  #
  def path(pt)
    return pt if pt.kind_of?(RGFA::Line)
    @records[:P][pt.to_sym]
  end

  # @!macro path
  # @raise [RGFA::NotFoundError] if no such path exists in the RGFA instance
  def path!(pt)
    pt = path(pt)
    raise RGFA::NotFoundError, "No path has name #{pt}" if pt.nil?
    pt
  end

  # Searches all containments of +contained+ in +container+.
  # Returns a possibly empty array of containments.
  #
  # @return [Array<RGFA::Line::Edge::Containment>]
  # @!macro [new] container_contained
  #   @param container [RGFA::Line::Segment::GFA1, Symbol]
  #     a segment instance or name
  #   @param contained [RGFA::Line::Segment::GFA1, Symbol]
  #     a segment instance or name
  #
  def containments_between(container, contained)
    segment!(container).contained.select {|l| l.to.to_sym == contained.to_sym }
  end

  # @!macro [new] segment
  #   Searches the segment with name equal to +segment_name+.
  #   @param s
  #     [Symbol, String, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #     segment name or instance
  #   @return [RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #     if a segment is found
  # @return [nil] if no such segment exists in the RGFA instance
  #
  def segment(s)
    return s if s.kind_of?(RGFA::Line)
    @records[:S][s.to_sym]
  end

  # @!macro segment
  # @raise [RGFA::NotFoundError] if no such segment exists
  def segment!(s)
    seg = segment(s)
    if seg.nil?
      raise RGFA::NotFoundError, "No segment has name #{s}"+
             "#{segment_names.size < 10 ?
               "\nSegment names: "+segment_names.inspect : ''}"
    end
    seg
  end

  # CHANGE2: directly use segment.dovetails
  # CHANGE2: rename to something like dovetail()
  # CHANGE3: how often is this used; this method has problems (multiple links)
  #          and something like the above links_between shall be used instead
  #
  # @!macro [new] link
  #   Searches a link between +segment_end1+ and +segment_end2+
  #   @!macro two_segment_ends
  #   @return [RGFA::Line::Edge::Link] the first link found
  # @return [nil] if no link is found.
  def link(segment_end1, segment_end2)
    segment_end1 = segment_end1.to_segment_end
    segment_end2 = segment_end2.to_segment_end
    s = segment!(segment_end1.segment)
    s.dovetails(segment_end1.end_type).each do |l|
      return l if l.other_end(segment_end1) == segment_end2
    end
    return nil
  end

  # CHANGE2: directly use segment.dovetails
  # CHANGE2: rename to something like dovetail!()
  # CHANGE3: how often is this used; this method has problems (multiple links)
  #          and something like the above links_between shall be used instead
  #
  # @!macro link
  # @raise [RGFA::NotFoundError] if no link is found.
  def link!(segment_end1, segment_end2)
    l = link(segment_end1, segment_end2)
    raise RGFA::NotFoundError,
      "No link was found: "+
          "#{segment_end1.to_s} -- "+
          "#{segment_end2.to_s}" if l.nil?
    l
  end

  # CHANGE1: use segment.dovetails instead of segment.links
  # CHANGE2: rename to search_dovetail_as_link() or something similar
  #
  # Search the link from a segment S1 in a given orientation
  # to another segment S2 in a given, or the equivalent
  # link from S2 to S1 with inverted orientations.
  #
  # @param [RGFA::OrientedSegment] oriented_segment1 a segment with orientation
  # @param [RGFA::OrientedSegment] oriented_segment2 a segment with orientation
  # @param [RGFA::Alignment::CIGAR] cigar
  # @return [RGFA::Line::Edge::Link] the first link found
  # @return [nil] if no link is found.
  def search_link(oriented_segment1, oriented_segment2, cigar)
    oriented_segment1 = oriented_segment1.to_oriented_segment
    oriented_segment2 = oriented_segment2.to_oriented_segment
    s = segment(oriented_segment1.segment)
    return nil if s.nil?
    s.dovetails.each do |l|
      return l if l.kind_of?(RGFA::Line::Edge::Link) and
        l.compatible?(oriented_segment1, oriented_segment2, cigar, true)
    end
    return nil
  end

  # @api private
  def search_duplicate(gfa_line)
    case gfa_line.record_type
    when :L
      search_link(gfa_line.oriented_from,
                  gfa_line.oriented_to, gfa_line.alignment)
    when :E, :S, :P, :U, :G, :O
      return search_by_name(gfa_line.name)
    else
      return nil
    end
  end

  # @api private
  def search_by_name(name)
    if name.kind_of?(RGFA::Placeholder)
      return nil
    end
    name = name.to_sym
    [:E, :S, :P, :U, :G, :O, nil].each do |rt|
      found = @records[rt][name]
      return found if !found.nil?
    end
    return nil
  end

end
