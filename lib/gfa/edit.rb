module GFA::Edit

  def multiply_segment!(segment_name, copy_names)
    s = get_segment(segment_name)
    if copy_names.empty?
      raise ArgumentError, "multiply factor must be at least 2"
    end
    factor = 1 + copy_names.size
    divide_counts(s, factor)
    ["L","C"].each do |rt|
      [:from,:to].each do |e|
        @connect[rt][e].fetch(s,[]).each do |i|
          l = @lines[rt][i]
          # circular link counts shall be divided only ones
          next if e == :to and l.from == l.to
          divide_counts(l, factor)
        end
      end
    end
    copy_names.each do |cn|
      if @segment_names.include?(cn)
        raise ArgumentError, "Segment with name #{cn} already exists"
      end
      cpy = s.clone
      cpy.name = cn
      self << cpy
    end
    ["L","C"].each do |rt|
      [:from,:to].each do |e|
        to_clone = []
        @connect[rt][e].fetch(segment_name,[]).each {|i| to_clone << i }
        copy_names.each do |cn|
          to_clone.each do |i|
            l = @lines[rt][i].clone
            l.send(:"#{e}=", cn)
            self << l
          end
        end
      end
    end
    return self
  end

  def duplicate_segment!(segment_name, copy_name)
    multiply_segment!(segment_name, [copy_name])
  end

  def delete_segment!(segment_name)
    i = @segment_names.index(segment_name)
    raise ArgumentError, "No segment has name #{segment_name}" if i.nil?
    s = @lines["S"][i]
    ["L","C"].each do |rt|
      [:from,:to].each do |e|
        @connect[rt][e].fetch(segment_name,[]).each {|li| @lines[rt][li] = nil}
        @connect[rt][e].delete(segment_name)
      end
    end
    to_rm = []
    @paths_with.fetch(segment_name,[]).each {|li| to_rm <<
                                             @lines["P"][li].path_name }
    to_rm.each {|pt| delete_path!(pt)}
    @lines["S"][i] = nil
    return self
  end

  def unconnect_segments!(from, to)
    delete_containments_or_links("C", from, nil, to, nil, nil, false)
    delete_containments_or_links("L", from, nil, to, nil, nil, false)
    delete_containments_or_links("C", to, nil, from, nil, nil, false)
    delete_containments_or_links("L", to, nil, from, nil, nil, false)
    return self
  end

  def delete_link!(from, from_orient, to, to_orient)
    delete_containments_or_links("L", from, from_orient, to,
                                 to_orient, nil, true)
  end

  def delete_containment!(from, from_orient, to, to_orient, pos)
    delete_containments_or_links("C", from, from_orient, to,
                                 to_orient, pos, true)
  end

  def delete_path!(path_name)
    i = @path_names.index(path_name)
    raise ArgumentError, "No path has name #{path_name}" if i.nil?
    pt = @lines["P"][i]
    pt.segment_name.each {|sn, o| @paths_with[sn].delete(i)}
    @lines["P"][i] = nil
    @path_names[i] = nil
    return self
  end

  private

  def divide_counts(gfa_line, factor)
    [:KC, :RC, :FC].each do |count_tag|
      if gfa_line.optional_fieldnames.include?(count_tag)
        value = (gfa_line.send(count_tag).to_f / factor)
        gfa_line.send(:"#{count_tag}=", value.to_i.to_s)
      end
    end
  end

  def delete_containments_or_links(rt, from, from_orient, to, to_orient, pos,
                                  firstonly = false)
    to_rm = []
    @connect[rt][:from].fetch(from,[]).each do |li|
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
      @connect[rt][:from].fetch(from,[]).delete(li)
      @connect[rt][:to].fetch(to,[]).delete(li)
    end
    return self
  end

end
