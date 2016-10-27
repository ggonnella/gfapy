#
# Methods for the RGFA class, which allow to handle segments in the graph.
#
module RGFA::Lines::Segments

  def add_segment(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    segment_name = gfa_line.name
    if @paths.has_key?(segment_name)
      raise RGFA::NotUniqueError,
        "Error when adding line: #{gfa_line}\n"+
        "a path already exists with the name: #{segment_name}\n"+
        "Path: #{@paths[segment_name]}"
    elsif @segments.has_key?(segment_name)
      if @segments[segment_name].virtual?
        @segments[segment_name].real!(gfa_line)
      else
        raise RGFA::NotUniqueError,
          "Error when adding line: #{gfa_line}\n"+
          "a segment already exists with the name: #{segment_name}\n"+
          "Segment: #{@segments[segment_name]}"
      end
    else
      @segments[segment_name] = gfa_line
    end
  end
  protected :add_segment

  # Delete a segment from the RGFA graph
  # @return [RGFA] self
  # @param s [String, RGFA::Line::Segment] segment name or instance
  def delete_segment(s, cascade=true)
    s = segment!(s)
    if cascade
      connected_segments(s).each {|cs| unconnect_segments(s, cs)}
      [:+, :-].each do |o|
        s.paths[o].each {|pt| delete_path(pt)}
      end
    end
    @segments.delete(s.name)
    return self
  end

  # All segment lines of the graph
  # @return [Array<RGFA::Line::Segment>]
  def segments
    @segments.values
  end

  # @!macro [new] segment
  #   Searches the segment with name equal to +segment_name+.
  #   @param s [String, RGFA::Line::Segment] a segment or segment name
  #   @return [RGFA::Line::Segment] if a segment is found
  # @return [nil] if no such segment exists in the RGFA instance
  #
  def segment(s)
    return s if s.kind_of?(RGFA::Line)
    @segments[s.to_sym]
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
  # @param segment1 [String, RGFA::Line::Segment] segment 1 name or instance
  # @param segment2 [String, RGFA::Line::Segment] segment 2 name or instance
  def unconnect_segments(segment1, segment2)
    containments_between(segment1, segment2).each {|c| delete_containment(c)}
    containments_between(segment2, segment1).each {|c| delete_containment(c)}
    [[:B, :E], [:B, :B], [:E, :B], [:E, :E]].each do |end1, end2|
      links_between([segment1, end1], [segment2, end2]).each do |l|
        delete_link(l)
      end
    end
    return self
  end

end
