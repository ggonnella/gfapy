#
# Methods for the GFA class, which allow to delete lines.
#
module GFA::LineDestructors

  def delete_segment(segment_name)
    i = @segment_names.index(segment_name)
    raise ArgumentError, "No segment has name #{segment_name}" if i.nil?
    s = @lines["S"][i]
    connected = []
    ["L","C"].each do |rt|
      [:from,:to].each do |e|
        connected +=
          @c.lines(rt,segment_name,e).map {|l| l.other(segment_name)}
      end
    end
    connected.uniq.each {|c| unconnect_segments(segment_name, c)}
    @c.lines("P",segment_name).each {|pt| delete_path(pt.path_name)}
    @c.delete_segment(segment_name)
    @lines["S"][i] = nil
    @segment_names[i] = nil
    return self
  end

  def unconnect_segments(from, to)
    delete_containments_or_links("C", from, nil, to, nil, nil, false)
    delete_containments_or_links("L", from, nil, to, nil, nil, false)
    delete_containments_or_links("C", to, nil, from, nil, nil, false)
    delete_containments_or_links("L", to, nil, from, nil, nil, false)
    return self
  end

  def delete_link(from, from_orient, to, to_orient)
    delete_containments_or_links("L", from, from_orient, to,
                                 to_orient, nil, true)
  end

  def delete_containment(from, from_orient, to, to_orient, pos)
    delete_containments_or_links("C", from, from_orient, to,
                                 to_orient, pos, true)
  end

  def delete_path(path_name)
    i = @path_names.index(path_name)
    raise ArgumentError, "No path has name #{path_name}" if i.nil?
    pt = @lines["P"][i]
    pt.segment_names.each {|sn, o| @c.delete("P",i,sn)}
    @lines["P"][i] = nil
    @path_names[i] = nil
    return self
  end

  def delete_headers
    @lines["H"] = ""
  end

  def delete_segment_line(segment_line)
    delete_segment(segment_line.name)
  end

  def delete_path_line(path_line)
    delete_path(path_line.name)
  end

  def delete_link_line(link_line)
    delete_containments_or_links("L",
                                 link_line.from,
                                 link_line.from_orient,
                                 link_line.to,
                                 link_line.to_orient,
                                 nil,
                                 true)
  end

  def delete_containment_line(containment_line)
    delete_containments_or_links("C",
                                 containment_line.from,
                                 containment_line.from_orient,
                                 containment_line.to,
                                 containment_line.to_orient,
                                 containment_line.pos,
                                 true)
  end

  private

  def delete_containments_or_links(rt, from, from_orient, to, to_orient, pos,
                                  firstonly = false)
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
