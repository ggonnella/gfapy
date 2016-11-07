#
# Methods for the RGFA class, which allow to handle segments in the graph.
#
module RGFA::Lines::Segments

  # All segment lines of the graph
  # @return [Array<RGFA::Line::SegmentGFA1,RGFA::Line::SegmentGFA2>]
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
  #     [Symbol, String, RGFA::Line::SegmentGFA1, RGFA::Line::SegmentGFA2]
  #     segment name or instance
  #   @return [RGFA::Line::SegmentGFA1, RGFA::Line::SegmentGFA2]
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

  # @return [Array<String>] list of names of segments connected to +segment+
  #   by links or containments
  def connected_segments(segment)
    (neighbours([segment, :B]).map{|s, e| s} +
      neighbours([segment, :E]).map{|s, e| s} +
        contained_in(segment).map{|c| c.to} +
          containing(segment).map{|c| c.from}).uniq
  end

  # Delete all links/containments involving two segments
  # @return [RGFA] self
  # @param segment1
  #   [Symbol, String, RGFA::Line::SegmentGFA1, RGFA::Line::SegmentGFA2]
  #   segment 1 name or instance
  # @param segment2
  #   [Symbol, String, RGFA::Line::SegmentGFA1, RGFA::Line::SegmentGFA2]
  #   segment 2 name or instance
  def unconnect_segments(segment1, segment2)
    containments_between(segment1, segment2).each {|c| c.disconnect!}
    containments_between(segment2, segment1).each {|c| c.disconnect!}
    [[:B, :E], [:B, :B], [:E, :B], [:E, :E]].each do |end1, end2|
      links_between([segment1, end1], [segment2, end2]).each do |l|
        l.disconnect!
      end
    end
    return self
  end

end
