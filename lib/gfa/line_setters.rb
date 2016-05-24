#
# Methods for the GFA class, which allow to add or delete single lines.
#
module GFA::LineSetters

  def <<(gfa_line)
    gfa_line = gfa_line.to_gfa_line
    rt = gfa_line.record_type
    i = @lines[rt].size
    @lines[rt] << gfa_line
    case rt
    when "S"
      validate_segment_and_path_name_unique!(gfa_line.name)
      @segment_names << gfa_line.name
    when "L", "C"
      [:from,:to].each do |e|
        sn = gfa_line.send(e)
        o = gfa_line.send(:"#{e}_orient")
        segment!(sn) if @segments_first_order
        connect(rt,e,sn,o,i)
      end
    when "P"
      validate_segment_and_path_name_unique!(gfa_line.path_name)
      @path_names << gfa_line.path_name
      gfa_line.segment_names.each do |sn, o|
        segment!(sn) if @segments_first_order
        @paths_with[sn] ||= []
        @paths_with[sn] << i
      end
    end
  end

  def validate!
    ["L", "C"].each do |rt|
      @lines[rt].each {|l| [:from,:to].each {|e| segment!(l.send(e))}}
    end
    @lines["P"].each {|l| l.segment_names.each {|sn, o| segment!(sn)}}
  end

  def delete_segment(segment_name)
    i = @segment_names.index(segment_name)
    raise ArgumentError, "No segment has name #{segment_name}" if i.nil?
    s = @lines["S"][i]
    connected = []
    validate_connect
    ["L","C"].each do |rt|
      [:from,:to].each do |e|
        connected +=
          connections(rt, e, segment_name).map do |c|
            l = @lines[rt][c]
            l.from == segment_name ? l.to : l.from
          end
      end
    end
    connected.uniq.each {|c| unconnect_segments(segment_name, c)}
    ["L","C"].each do |rt|
      [:from,:to].each do |e|
        disconnect(rt,e,segment_name,nil,nil)
      end
    end
    to_rm = []
    @paths_with.fetch(segment_name,[]).each {|li| to_rm <<
                                             @lines["P"][li].path_name }
    to_rm.each {|pt| delete_path(pt)}
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

  # TODO: the interface of link and containment is now very different to that
  #       of delete_link and delete_containment; shall the latter remain so?

  def delete_link(from, to, from_orient: nil, to_orient: nil)
    delete_containments_or_links("L", from, from_orient, to,
                                 to_orient, nil, true)
  end

  def delete_containment(from, to, from_orient: nil, to_orient: nil, pos: nil)
    delete_containments_or_links("C", from, from_orient, to,
                                 to_orient, pos, true)
  end

  def delete_path(path_name)
    i = @path_names.index(path_name)
    raise ArgumentError, "No path has name #{path_name}" if i.nil?
    pt = @lines["P"][i]
    pt.segment_names.each {|sn, o| @paths_with[sn].delete(i)}
    @lines["P"][i] = nil
    @path_names[i] = nil
    return self
  end

  private

  def validate_segment_and_path_name_unique!(sn)
    if @segment_names.include?(sn) or @path_names.include?(sn)
      raise ArgumentError, "Segment or path name not unique '#{sn}'"
    end
  end

  def delete_containments_or_links(rt, from, from_orient, to, to_orient, pos,
                                  firstonly = false)
    to_rm = []
    connections(rt,:from,from).each do |li|
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
      disconnect(rt,:from,from,nil,li)
      disconnect(rt,:to,to,nil,li)
    end
    validate_connect if $DEBUG
    return self
  end

end
