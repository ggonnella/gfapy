#
# Methods for the GFA class, which allow to delete lines.
#
module GFA::LineDestructors

  def delete_segment(segment_name, cascade=true)
    i = @segment_names.index(segment_name)
    raise ArgumentError, "No segment has name #{segment_name}" if i.nil?
    if cascade
      connected_segments(segment_name).each do |c|
        unconnect_segments(segment_name, c)
      end
      @c.lines("P",segment_name).each {|pt| delete_path(pt.path_name)}
      @c.delete_segment(segment_name)
    end
    @lines["S"][i] = nil
    @segment_names[i] = nil
    return self
  end

  def rm(x, *args)
    if x.kind_of?(GFA::Line)
      raise "One argument required if first GFA::Line" if !args.empty?
      case x.record_type
      when "H" then raise "Cannot remove single header lines"
      when "S" then delete_segment_line(x)
      when "L" then delete_link_line(x)
      when "P" then delete_path_line(x)
      when "C" then delete_containment_line(x)
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
    elsif x.kind_of?(String) and @segment_names.include?(x)
      if args.empty?
        delete_segment(x)
      elsif args.size != 3
        raise "1 or 3 arguments required if first segment name"
      else
        delete_containments_or_links("C", x, args[0], args[1], args[2],
                                     nil, false)
        delete_containments_or_links("L", x, args[0], args[1], args[2],
                                     nil, false)
      end
    elsif x.kind_of?(String) and @path_names.include?(x)
      raise "One argument required if first path name" if !args.empty?
      delete_path(x)
    elsif x.kind_of?(Array)
      x.each {|elem| rm(elem, *args)}
    elsif x.nil?
      return nil
    else
      raise "Cannot remove #{x.inspect}"
    end
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
    @lines["H"] = []
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

  def delete_other_links(segment_end, other_end)
    links_of(segment_end).each do |l|
      delete_link_line(l) if l.other_end(segment_end) != other_end
    end
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
