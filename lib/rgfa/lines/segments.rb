#
# Methods for the RGFA class, which allow to handle segments in the graph.
#
module RGFA::Lines::Segments

  # All segment lines of the graph
  # @return [Array<RGFA::Line::Segment::GFA1,RGFA::Line::Segment::GFA2>]
  def segments
    @records[:S].values
  end

  # List all names of segments in the graph
  # @return [Array<Symbol>]
  def segment_names
    @records[:S].keys
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

  # Delete all links/containments involving two segments
  # @return [RGFA] self
  # @param segment1
  #   [Symbol, String, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #   segment 1 name or instance
  # @param segment2
  #   [Symbol, String, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #   segment 2 name or instance
  def unconnect_segments(segment1, segment2)
    segment1 = segment!(segment1)
    segment2 = segment!(segment2)
    containments_between(segment1, segment2).each {|c| c.disconnect!}
    containments_between(segment2, segment1).each {|c| c.disconnect!}
    segment1.dovetails.each {|l| l.disconnect! if l.other(segment1) == segment2}
    return self
  end

end
