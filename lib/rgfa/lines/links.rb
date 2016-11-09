#
# Methods for the RGFA class, which allow to handle links in the graph.
#
module RGFA::Lines::Links

  # Remove all links of a segment end end except that to the other specified
  # segment end.
  # @param segment_end [RGFA::SegmentEnd] the segment end
  # @param other_end [RGFA::SegmentEnd] the other segment end
  # @param conserve_components [Boolean] <i>(defaults to: +false+)</i>
  #   Do not remove links if removing them breaks the graph into unconnected
  #   components.
  # @return [RGFA] self
  def delete_other_links(segment_end, other_end, conserve_components: false)
    other_end = other_end.to_segment_end
    links_of(segment_end).each do |l|
      if l.other_end(segment_end) != other_end
        if !conserve_components or !cut_link?(l)
          l.disconnect!
        end
      end
    end
  end

  # All links of the graph
  # @return [Array<RGFA::Line::Edge::Link>]
  def links
    @records[:L]
  end

  # CHANGE2: calling code shall directly use segment.dovetails
  #
  # Finds links of the specified end of segment.
  #
  # @param [RGFA::SegmentEnd] segment_end a segment end
  #
  # @return [Array<RGFA::Line::Edge::Link>] if segment_end[1] == :E,
  #   links from sn with from_orient + and to sn with to_orient -
  # @return [Array<RGFA::Line::Edge::Link>] if segment_end[1] == :B,
  #   links to sn with to_orient + and from sn with from_orient -
  #
  # CHANGE1:
  # @note to add or remove links, use the appropriate methods;
  #   adding or removing links from the returned array will not work
  def links_of(segment_end)
    segment_end = segment_end.to_segment_end
    s = segment!(segment_end.segment)
    s.dovetails(segment_end.end_type == :B ? :L : :R)
  end

  # CHANGE2: directly use segment.dovetails
  #
  # Finds segment ends connected to the specified segment end.
  #
  # @param [RGFA::SegmentEnd] segment_end a segment end
  #
  # @return [Array<RGFA::SegmentEnd>>] segment ends connected by links
  #   to +segment_end+
  def neighbours(segment_end)
    s = segment!(segment_end.segment)
    s.dovetails(segment_end.end_type == :B ? :L : :R).map do |l|
      l.other_end(segment_end)
    end
  end

  # CHANGE2: directly use segment.dovetails
  # CHANGE2: rename to something like dovetails_between
  #
  # Searches all links between +segment_end1+ and +segment_end2+
  #
  # @!macro [new] two_segment_ends
  #   @param segment_end1 [RGFA::SegmentEnd] a segment end
  #   @param segment_end2 [RGFA::SegmentEnd] a segment end
  # @return [Array<RGFA::Line::Edge::Link>] (possibly empty)
  def links_between(segment_end1, segment_end2)
    segment_end1 = segment_end1.to_segment_end
    segment_end2 = segment_end2.to_segment_end
    links_of(segment_end1).select do |l|
      l.other_end(segment_end1) == segment_end2
    end
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
    links_of(segment_end1).each do |l|
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
  # @param [RGFA::CIGAR] cigar
  # @return [RGFA::Line::Edge::Link] the first link found
  # @return [nil] if no link is found.
  def search_link(oriented_segment1, oriented_segment2, cigar)
    oriented_segment1 = oriented_segment1.to_oriented_segment
    oriented_segment2 = oriented_segment2.to_oriented_segment
    s = segment(oriented_segment1.segment)
    return nil if s.nil?
    (s.dovetails(:L) + s.dovetails(:R)).select do |l|
      return l if l.kind_of?(RGFA::Line::Edge::Link) and
        l.compatible?(oriented_segment1, oriented_segment2, cigar, true)
    end
    return nil
  end

end
