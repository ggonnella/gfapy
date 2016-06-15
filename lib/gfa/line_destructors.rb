#
# Methods for the GFA class, which allow to delete lines.
#
module GFA::LineDestructors

  # Delete elements from the GFA graph
  # @overload rm(segment)
  #   @param segment [String, GFA::Line::Segment] segment name or instance
  # @overload rm(path)
  #   @param path [String, GFA::Line::Segment] path name or instance
  # @overload rm(segment1, segment1_orient, segment2, segment2_orient)
  #   Remove all links/containments where segment1 is the "From segment
  #   and segment2 is the "To" segment
  #   @param segment1 [String, GFA::Line::Segment] segment 1 name or instance
  #   @param segment1_orient [GFA::Line::Segment::ORIENTATION]
  #      orientation of segment 1
  #   @param segment2 [String, GFA::Line::Segment] segment 2 name or instance
  #   @param segment2_orient [GFA::Line::Segment::ORIENTATION]
  #      orientation of segment 2
  # @overload rm(:sequences)
  #   Replace all sequences with "*"
  # @overload rm(:headers)
  #   Remove all headers
  # @overload rm(:alignments)
  #   Replace all CIGAR strings with "*"
  # @overload rm(array)
  #   Calls {#rm} using each element of the array as argument
  #   @param array [Array]
  # @overload rm(method_name, *args)
  #   Call a method of GFA instance, then {#rm} for each returned value
  #   @param method_name [Symbol] method to call
  #   @param args arguments of the method
  # @return [GFA] self
  def rm(x, *args)
    if x.kind_of?(GFA::Line)
      raise "One argument required if first GFA::Line" if !args.empty?
      case x.record_type
      when "H" then raise "Cannot remove single header lines"
      when "S" then delete_segment(x)
      when "P" then delete_path(x)
      when "L" then delete_link(x)
      when "C" then delete_containment(x)
      end
    elsif x.kind_of?(Symbol)
      case x
      when :sequences
        raise "One argument required if first #{x.inspect}" if !args.empty?
        delete_sequences
      when :headers
        raise "One argument required if first #{x.inspect}" if !args.empty?
        delete_headers
      when :alignments
        raise "One argument required if first #{x.inspect}" if !args.empty?
        delete_alignments
      else
        if respond_to?(x)
          rm(send(x, *args))
        else
          raise "Cannot remove #{x.inspect}"
        end
      end
    elsif x.kind_of?(String) and @segment_names.has_key?(x.to_sym)
      if args.empty?
        delete_segment(x)
      elsif args.size != 3
        raise "1 or 4 arguments required if first segment name"
      else
        delete_containments_or_links("C", x, args[0], args[1], args[2],
                                     nil, false)
        delete_containments_or_links("L", x, args[0], args[1], args[2],
                                     nil, false)
      end
    elsif x.kind_of?(String) and @path_names.has_key?(x.to_sym)
      raise "One argument required if first path name" if !args.empty?
      delete_path(x)
    elsif x.kind_of?(Array)
      x.each {|elem| rm(elem, *args)}
    elsif x.nil?
      return self
    else
      raise "Cannot remove #{x.inspect}"
    end
    return self
  end

  # Delete a segment from the GFA graph
  # @return [GFA] self
  # @param segment [String, GFA::Line::Segment] segment name or instance
  def delete_segment(segment, cascade=true)
    segment_name = segment.kind_of?(GFA::Line::Segment) ? segment.name : segment
    i = @segment_names[segment_name.to_sym]
    raise ArgumentError, "No segment has name #{segment_name}" if i.nil?
    if cascade
      connected_segments(segment_name).each do |c|
        unconnect_segments(segment_name, c)
      end
      @c.lines("P",segment_name).each {|pt| delete_path(pt.path_name)}
      @c.delete_segment(segment_name)
    end
    @lines["S"][i] = nil
    @segment_names.delete(segment_name.to_sym)
    return self
  end

  # Delete all links/containments involving two segments
  # @return [GFA] self
  # @param segment1 [String, GFA::Line::Segment] segment 1 name or instance
  # @param segment2 [String, GFA::Line::Segment] segment 2 name or instance
  def unconnect_segments(segment1, segment2)
    delete_containments_or_links("C", segment1, nil, segment2, nil, nil, false)
    delete_containments_or_links("L", segment1, nil, segment2, nil, nil, false)
    delete_containments_or_links("C", segment2, nil, segment1, nil, nil, false)
    delete_containments_or_links("L", segment2, nil, segment1, nil, nil, false)
    return self
  end

  # @!macro [new] from_to
  #   @param from [String, GFA::Line::Segment] segment name or instance
  #   @param from_orient [nil, GFA::Line::Segment::ORIENTATION]
  #      orientation of from segment (use nil for both orientations)
  #   @param to [String, GFA::Line::Segment] segment name or instance
  #   @param to_orient [nil, GFA::Line::Segment::ORIENTATION]
  #      orientation of to segment (use nil for both orientations)

  # Delete a link from a segment to another
  #
  # @overload delete_link(from, from_orient, to, to_orient)
  #   @macro from_to
  # @overload delete_link(link)
  #   @param link [GFA::Line::Link] link instance
  # @return [GFA] self
  def delete_link(from, from_orient=nil, to=nil, to_orient=nil)
    if from.kind_of?(GFA::Line::Link)
      to = from.to
      to_orient = from.to_orient
      from_orient = from.from_orient
      from = from.from
    else
      raise "To segment not specified" if to.nil?
    end
    delete_containments_or_links("L", from, from_orient, to,
                                 to_orient, nil, true)
  end

  # Delete a containment of a segment in another, with given orientations and
  # starting position
  #
  # @overload delete_containment(from, from_orient, to, to_orient, pos)
  #   @macro from_to
  #   @param pos [Integer, nil] starting position (any if nil)
  # @overload delete_containment(containment)
  #   @param containment [GFA::Line::Containment] containment instance
  # @return [GFA] self
  def delete_containment(from, from_orient=nil, to=nil, to_orient=nil, pos=nil)
    if from.kind_of?(GFA::Line::Containment)
      to = from.to
      to_orient = from.to_orient
      from_orient = from.from_orient
      pos = from.pos
      from = from.from
    else
      raise "To segment not specified" if to.nil?
    end
    delete_containments_or_links("C", from, from_orient, to,
                                 to_orient, pos, true)
  end

  # Delete a path from the GFA graph
  # @return [GFA] self
  # @param path [String, GFA::Line::Path] path name or instance
  def delete_path(path)
    path_name = path.kind_of?(GFA::Line::Path) ? path.name : path
    i = @path_names[path_name.to_sym]
    raise ArgumentError, "No path has name #{path_name}" if i.nil?
    pt = @lines["P"][i]
    pt.segment_names.each {|sn, o| @c.delete("P",i,sn)}
    @lines["P"][i] = nil
    @path_names.delete(path_name.to_sym)
    return self
  end

  # Remove all headers
  # @return [GFA] self
  def delete_headers
    @lines["H"] = []
  end

  # Remove all links of a segment end end except that to the other specified
  # segment end.
  # @param segment_end [GFA::SegmentEnd] the segment end
  # @param other_end [GFA::SegmentEnd] the other segment end
  # @param conserve_components [Boolean] <i>(defaults to: +false+)</i>
  #   Do not remove links if removing them breaks the graph into unconnected
  #   components.
  # @return [GFA] self
  def delete_other_links(segment_end, other_end,
                         conserve_components: false)
    links_of(segment_end).each do |l|
      if l.other_end(segment_end) != other_end
        if !conserve_components or !cut_link?(l)
          delete_link_line(l)
        end
      end
    end
  end

  private

  def delete_containments_or_links(rt, from, from_orient, to, to_orient, pos,
                                  firstonly = false)
    from = from.kind_of?(GFA::Line::Segment) ? from.name : from
    to = to.kind_of?(GFA::Line::Segment) ? to.name : to
    to_rm = []
    @c.find(rt,from,:from).each do |li|
      l = @lines[rt][li]
      if (l.to == to) and
         (to_orient.nil? or (l.to_orient == to_orient)) and
         (from_orient.nil? or (l.from_orient == from_orient)) and
         (pos.nil? or (l.pos(false) == pos.to_s))
        to_rm << li
        break if firstonly
      end
    end
    to_rm.each do |li|
      @lines[rt][li] = nil
      @c.delete(rt,li,from,:from,nil)
      @c.delete(rt,li,to,:to,nil)
    end
    validate_connect if $DEBUG
    return self
  end

end
