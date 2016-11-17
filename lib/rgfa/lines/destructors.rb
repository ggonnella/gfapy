#
# Methods for the RGFA class, which allow to add lines.
#
module RGFA::Lines::Destructors

  # Delete elements from the RGFA graph
  # @overload rm(segment)
  #   @param segment
  #     [Symbol, String, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #     segment name or instance
  # @overload rm(path)
  #   @param path [String, Symbol, RGFA::Line::Path]
  #     path name or instance
  # @overload rm(link)
  #   @param link [RGFA::Line::Edge::Link] link line instance
  # @overload rm(containment)
  #   @param containment [RGFA::Line::Edge::Containment] containment line instance
  # @overload rm(comment)
  #   @param comment [RGFA::Line::Comment] comment line instance
  # @overload rm(custom_record)
  #   @param custom_record [RGFA::Line::CustomRecord] custom record instance
  # @overload rm(array)
  #   Calls {#rm} using each element of the array as argument
  #   @param array [Array]
  # @overload rm(method_name, *args)
  #   Call a method of RGFA instance, then {#rm} for each returned value
  #   @param method_name [Symbol] method to call
  #   @param args arguments of the method
  # @return [RGFA] self
  def rm(x, *args)
    case x
    when RGFA::Line
      raise RGFA::ArgumentError,
        "One argument required if first RGFA::Line" if !args.empty?
      case x.record_type
      when :H then raise RGFA::ArgumentError,
                           "Cannot remove single header lines"
      else
        x.disconnect!
      end
    when Symbol, String
      x = x.to_sym
      l = search_by_name(x)
      if l
        if !args.empty?
          raise RGFA::ArgumentError,
            "One arguments required if first argument is an ID"
        end
        l.disconnect!
      else
        if respond_to?(x)
          rm(send(x, *args))
        else
          raise RGFA::ArgumentError, "Cannot remove #{x.inspect}"
        end
      end
    when Array
      x.each {|elem| rm(elem, *args)}
    when nil, RGFA::Placeholder
      return self
    else
      raise RGFA::ArgumentError, "Cannot remove #{x.inspect}"
    end
    return self
  end

  # @api private
  def unregister_line(gfa_line)
    api_private_check_gfa_line(gfa_line, "unregister_line")
    case gfa_line.record_type
    when :H
      raise RGFA::AssertionError, "Bug found, please report\n"+
        "gfa_line: #{gfa_line}"
    when :E, :S, :P, :U, :G, :O
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
