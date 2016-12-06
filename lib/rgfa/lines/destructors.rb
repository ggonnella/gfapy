#
# Methods for the RGFA class, which allow to add lines.
#
module RGFA::Lines::Destructors

  # Delete a line from the RGFA graph
  # @param line [RGFA::Line, Symbol] a line instance or identifier
  # @return [RGFA] self
  def rm(line, *args)
    if line.kind_of?(Symbol)
      lineid = line
      line = search_by_name(line.to_sym)
      if !line
        raise RGFA::NotFoundError,
          "No line was found with ID '#{lineid}'"
      end
    end
    line.disconnect
    return self
  end

  # @api private
  def unregister_line(gfa_line)
    api_private_check_gfa_line(gfa_line, "unregister_line")
    case gfa_line.record_type
    when :H
      raise RGFA::AssertionError, "Bug found, please report\n"+
        "gfa_line: #{gfa_line}"
    when :E, :S, :P, :U, :G, :O, nil
      if gfa_line.name.empty?
        @records[gfa_line.record_type][nil].delete(gfa_line)
      else
        @records[gfa_line.record_type].delete(gfa_line.name)
      end
    else
      @records[gfa_line.record_type].delete(gfa_line)
    end
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
    containments_between(segment1, segment2).each {|c| c.disconnect}
    containments_between(segment2, segment1).each {|c| c.disconnect}
    segment1.dovetails.each {|l| l.disconnect if l.other(segment1) == segment2}
    return self
  end

  # Remove all links of a segment end end except that to the other specified
  # segment end.
  # @param segment_end [RGFA::SegmentEnd] the segment end
  # @param other_end [RGFA::SegmentEnd] the other segment end
  # @param conserve_components [Boolean] <i>(defaults to: +false+)</i>
  #   Do not remove links if removing them breaks the graph into unconnected
  #   components.
  # @return [RGFA] self
  def delete_other_links(segment_end, other_end, conserve_components: false)
    segment_end = segment_end.to_segment_end
    other_end = other_end.to_segment_end
    s = segment!(segment_end.segment)
    s.dovetails(segment_end.end_type).each do |l|
      if l.other_end(segment_end) != other_end
        if !conserve_components or !cut_link?(l)
          l.disconnect
        end
      end
    end
  end

end
