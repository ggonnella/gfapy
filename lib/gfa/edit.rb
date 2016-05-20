#
# Methods for the GFA class, which allow to change the content of the graph
#
module GFA::Edit

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
        validate_segment_name_exists!(sn)
        connect(rt,e,sn,o,i)
      end
    when "P"
      validate_segment_and_path_name_unique!(gfa_line.path_name)
      @path_names << gfa_line.path_name
      gfa_line.segment_name.each do |sn, o|
        validate_segment_name_exists!(sn)
        @paths_with[sn] ||= []
        @paths_with[sn] << i
      end
    end
  end

  # Eliminate the sequences from S lines
  def delete_sequences
    @lines["S"].each {|l| l.sequence = "*"}
  end

  # Eliminate the CIGAR from L/C/P lines
  def delete_alignments
    @lines["L"].each {|l| l.overlap = "*"}
    @lines["C"].each {|l| l.cigar = "*"}
    @lines["P"].each {|l| l.cigar = "*"}
  end

  def multiply_segment!(segment_name, copy_names)
    s = segment(segment_name)
    if copy_names.empty?
      raise ArgumentError, "multiply factor must be at least 2"
    end
    factor = 1 + copy_names.size
    divide_counts(s, factor)
    ["L","C"].each do |rt|
      [:from,:to].each do |e|
        connections(rt,e,s).each do |i|
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
        connections(rt,e,segment_name).each {|i| to_clone << i }
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

=begin comment
  def merge_unbranched_segpath!(segment_names)
    (segment_names.size - 1).times do |i|
      current = segment_names[i]
      after_links = link(current, other)
      raise if after_links.size != 1
      after_l = after_links.first
      after = after_l.other(current)
    end
  end

=end commment

  # limitations:
  # - all containments und paths involving merged segments are deleted
  def merge_unbranched_segpath!(segment_names)
    raise if segment_names.size < 2
    raise if segment_names[1..-2].any? do |sn|
      segment_junction_type(sn) != :internal
    end
    merged = segment(segment_names[0]).clone
    merged.name = segment_names.join("_")
    merged.sequence = joined_sequences(segment_names)
    sum_of_counts(segment_names).each do |count_tag, count|
      merged.send(:"#{count_tag}=", count)
    end
    l = link(segment_names[0],nil,segment_names[1],nil)
    first_reversed = (l.end_type(segment_names[0]) == :B)
    l = link(segment_names[-2],nil,segment_names[-1],nil)
    last_reversed = (l.end_type(segment_names[-1]) == :E)
    self << merged
    links_of(segment_names.first, nil).each do |l|
      l2 = l.clone
      if l2.to == segment_names.first
        l2.to = merged.name
        if first_reversed
          l2.to_orient = GFA::Line.other_orientation(l2.to_orient)
        end
      else
        l2.from = merged.name
        if first_reversed
          l2.from_orient = GFA::Line.other_orientation(l2.from_orient)
        end
      end
      self << l2
    end
    links_of(segment_names.last, nil).each do |l|
      l2 = l.clone
      if l2.from == segment_names.last
        l2.from = merged.name
        if last_reversed
          l2.from_orient = GFA::Line.other_orientation(l2.from_orient)
        end
      else
        l2.to = merged.name
        if last_reversed
          l2.to_orient = GFA::Line.other_orientation(l2.to_orient)
        end
      end
      self << l2
    end
    segment_names.each {|sn| delete_segment!(sn)}
    self
  end

  def merge_all_unbranched_segpaths!
    paths = unbranched_segpaths
    paths.each {|path| merge_unbranched_segpath!(path)}
    self
  end

  def delete_segment!(segment_name)
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
    connected.uniq.each {|c| unconnect_segments!(segment_name, c)}
    ["L","C"].each do |rt|
      [:from,:to].each do |e|
        disconnect(rt,e,segment_name,nil,nil)
      end
    end
    to_rm = []
    @paths_with.fetch(segment_name,[]).each {|li| to_rm <<
                                             @lines["P"][li].path_name }
    to_rm.each {|pt| delete_path!(pt)}
    @lines["S"][i] = nil
    @segment_names[i] = nil
    return self
  end

  def unconnect_segments!(from, to)
    delete_containments_or_links("C", from, nil, to, nil, nil, false)
    delete_containments_or_links("L", from, nil, to, nil, nil, false)
    delete_containments_or_links("C", to, nil, from, nil, nil, false)
    delete_containments_or_links("L", to, nil, from, nil, nil, false)
    return self
  end

  def delete_link!(from, to, from_orient: nil, to_orient: nil)
    delete_containments_or_links("L", from, from_orient, to,
                                 to_orient, nil, true)
  end

  def delete_containment!(from, to, from_orient: nil, to_orient: nil, pos: nil)
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

  def delete_low_coverage_segments!(mincov, count_tag: :RC)
    segments.map do |s|
      (s.send(count_tag).to_f / s.LN) < mincov ? s.name : nil
    end.compact.each do |sn|
      delete_segment!(sn)
    end
  end

  private

  # Add values to @connect data structure
  def connect(rt, dir, sn, o, value)
    raise if rt != "L" and rt != "C"
    raise if dir != :from and dir != :to
    raise if o != "+" and o != "-"
    @connect[rt][dir][sn]||={}
    @connect[rt][dir][sn][o]||=[]
    @connect[rt][dir][sn][o] << value
    validate_connect
  end

  # Remove values from @connect data structure
  #
  # Usage:
  # - disconnect(rt, dir, sn, o, value) => rm value from @connect
  # - disconnect(rt, dir, sn, nil, nil) => rm all sn connections
  # - disconnect(rt, dir, sn, nil, value) => rm value from both "+" and "-"
  #                                          connections of sn
  def disconnect(rt, dir, sn, o, value)
    raise if rt != "L" and rt != "C"
    raise if dir != :from and dir != :to
    if o.nil?
      if value.nil?
        @connect[rt][dir].delete(sn)
      else
        disconnect(rt, dir, sn, "+", value)
        disconnect(rt, dir, sn, "-", value)
      end
      return
    end
    raise if o != "+" and o != "-"
    raise if value.nil?
    @connect[rt][dir].fetch(sn,{}).fetch(o,[]).delete(value)
  end

  def validate_segment_and_path_name_unique!(sn)
    if @segment_names.include?(sn) or @path_names.include?(sn)
      raise ArgumentError, "Segment or path name not unique '#{sn}'"
    end
  end

  def validate_segment_name_exists!(sn)
    if !@segment_names.include?(sn)
      raise ArgumentError, "Link line refer to unknown segment '#{sn}'"
    end
  end

  def divide_counts(gfa_line, factor)
    [:KC, :RC, :FC].each do |count_tag|
      if gfa_line.optional_fieldnames.include?(count_tag)
        value = (gfa_line.send(count_tag).to_f / factor)
        gfa_line.send(:"#{count_tag}=", value.to_i.to_s)
      end
    end
  end

  def sum_of_counts(segnames)
    retval = {}
    segs = segnames.map {|sn|segment(sn)}
    [:KC, :RC, :FC].each do |count_tag|
      segs.each do |s|
        if s.optional_fieldnames.include?(count_tag)
          retval[count_tag] ||= 0
          retval[count_tag] += s.send(count_tag)
        end
      end
    end
    return retval
  end

  def joined_sequences(segnames)
    retval = ""
    (segnames.size-1).times do |i|
      a = segnames[i]
      b = segnames[i+1]
      l = link!(a, nil, b, nil)
      a = segment!(a)
      b = segment!(b)
      return "*" if a.sequence == "*" or b.sequence == "*"
      if l.overlap == "*"
        cut = 0
      elsif l.overlap.size == 1 and l.overlap[0][1] == "M"
        cut = l.overlap[0][0]
      else
        raise "Overlaps contaning other operations than M are not supported"
      end
      if retval.empty?
        retval << (l.end_type(a.name) == :E ? a.sequence : a.sequence.rc)
      end
      seq = (l.end_type(b.name) == :B ? b.sequence : b.sequence.rc)
      if cut > 0
        raise "Inconsistent overlap" if retval[(-cut)..-1] != seq[0..(cut-1)]
      end
      retval << seq[cut..-1]
    end
    return retval
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
