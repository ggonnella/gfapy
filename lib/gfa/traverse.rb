#
# Methods for the GFA class, which involve a traversal of the graph following
# links
#
module GFA::Traverse

  require "set"

  # Computes the connectivity of a segment from its number of links.
  #
  # *Arguments*:
  #   - +segment_name+: name of the segment
  #   - +reverse_complement+ use the reverse complement of the segment sequence
  #
  # *Returns*:
  #   - [b, e], where:
  #      - bn is the number of links to the beginning of the sequence
  #      - en is the number of links to the end of the sequence
  #      - b = :M if bn > 1, otherwise bn
  #      - e = :M if en > 1, otherwise en
  #
  def connectivity(segment_name, reverse_complement = false)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    ends = [:B, :E]
    ends.reverse! if reverse_complement
    connectivity_symbols(links_of([segment_name, ends.first]).size,
                         links_of([segment_name, ends.last]).size)
  end

  # Find a path without branches which includes segment +segment_name+
  # and excludes any segment whose name is stored in +exclude+.
  #
  # *Side effects*:
  #   - any segment used in the path will be added to +exclude+
  #
  # *Returns*:
  #   - an array of segment names
  def linear_path(segment_name, exclude = Set.new)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    cs = connectivity(segment_name)
    segpath = []
    [:B, :E].each_with_index do |et, i|
      if cs[i] == 1
        exclude << segment_name
        segpath.pop
        segpath += traverse_linear_path([segment_name, et], exclude)
      end
    end
    return (segpath.size < 2) ? nil : segpath
  end

  # Find all unbranched paths of segments connected by links in the graph.
  def linear_paths
    exclude = Set.new
    paths = []
    segnames = segment_names
    progress_log_init(:linear_paths, "segments", segnames.size,
      "Detect linear paths (#{segnames.size} segments)")  if @progress
    segnames.each do |sn|
      progress_log(:linear_paths) if @progress
      next if exclude.include?(sn)
      paths << linear_path(sn, exclude)
    end
    progress_log_end(:linear_paths)
    return paths.compact
  end

  # limitations:
  # - all containments und paths involving merged segments are deleted
  def merge_linear_path(segpath, **options)
    raise if segpath.size < 2
    raise if segpath[1..-2].any? {|sn,et| connectivity(sn) != [1,1]}
    merged, first_reversed, last_reversed =
                              create_merged_segment(segpath, options)
    self << merged
    link_merged(merged.name, other_segment_end(segpath.first), first_reversed)
    link_merged(merged.name, segpath.last, last_reversed)
    segpath.each do |sn, et|
      delete_segment(sn)
      progress_log(:merge_linear_paths, 0.05) if @progress
    end
    self
  end

  def merge_linear_paths(**options)
    paths = linear_paths
    psize = paths.flatten.size / 2
    progress_log_init(:merge_linear_paths, "segments", psize,
      "Merge #{paths.size} linear paths (#{psize} segments)") if @progress
    paths.each do |path|
      merge_linear_path(path, **options)
    end
    progress_log_end(:merge_linear_paths)
    self
  end

  def cut_link?(link)
    return false if link.circular?
    return true if links_of(other_segment_end(link.from_end)).size == 0
    return true if links_of(other_segment_end(link.to_end)).size == 0
    c = {}
    [:from, :to].each do |et|
      c[et] = Set.new
      visited = Set.new
      segend = link.send(:"#{et}_end")
      visited << segend[0]
      visited << link.other_end(segend)[0]
      traverse_component(segend, c[et], visited)
    end
    return c[:from] != c[:to]
  end

  def cut_segment?(segment_name)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    cn = connectivity(segment_name)
    return false if [[0,0],[0,1],[1,0]].include?(cn)
    start_points = []
    [:B, :E].each do |et|
      start_points += links_of([segment_name, et]).map do |l|
        other_segment_end(l.other_end([segment_name, et]))
      end
    end
    cc = []
    start_points.uniq.each do |start_point|
      cc << Set.new
      visited = Set.new
      visited << segment_name
      traverse_component(start_point, cc.last, visited)
    end
    return cc.any?{|c|c != cc[0]}
  end

  def segment_connected_component(segment_name, visited = Set.new)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    visited << segment_name
    c = [segment_name]
    traverse_component([segment_name, :B], c, visited)
    traverse_component([segment_name, :E], c, visited)
    return c
  end

  def connected_components
    components = []
    visited = Set.new
    segment_names.each do |sn|
      next if visited.include?(sn)
      components << segment_connected_component(sn, visited)
    end
    return components
  end

  def split_connected_components
    retval = []
    ccs = connected_components
    ccs.each do |cc|
      gfa2 = self.clone
      gfa2.rm(gfa2.segment_names - cc)
      retval << gfa2
    end
    return retval
  end

  private

  def traverse_component(segment_end, c, visited)
    links_of(segment_end).each do |l|
      oe = l.other_end(segment_end)
      sn = oe[0]
      next if visited.include?(sn)
      visited << sn
      c << sn
      traverse_component([sn, :B], c, visited)
      traverse_component([sn, :E], c, visited)
    end
  end

  def connectivity_symbols(n,m)
    [connectivity_symbol(n), connectivity_symbol(m)]
  end

  def connectivity_symbol(n)
    n > 1 ? :M : n
  end

  # Traverse the links, starting from the segment +from+ :E end if
  # +traverse_from_E_end+ is true, or :B end otherwise.
  #
  # If any segment after +from+ is found whose name is included in +exclude+
  # the traversing is interrupted. The +exclude+ set is updated, so that
  # circular paths are avoided.
  #
  # *Arguments*:
  #   - +from+ -> first segment
  #   - +traverse_from_E_end+ -> if true, start from E end, otherwise from B end
  #   - +exclude+ -> Set of names of already visited segments
  #
  # *Side Effects*:
  #   - Any element added to the returned list is also added to +exclude+
  #
  # *Returns*:
  #   - An array of segment names of the unbranched path.
  #     If +from+ is not an element of an unbranched path then [].
  #     Otherwise the first (and possibly only) element is +from+.
  #     All elements in the index range 1..-2 are :internal.
  def traverse_linear_path(segment_end, exclude)
    list = []
    current = segment_end
    loop do
      after  = links_of(current)
      before = links_of(other_segment_end(current))
      cs = connectivity_symbols(before.size, after.size)
      if cs == [1,1] or list.empty?
        list << current
        exclude << current[0]
        l = after.first
        current = other_segment_end(l.other_end(current))
        break if exclude.include?(current[0])
      elsif cs[0] == 1
        list << current
        exclude << current[0]
        break
      else
        break
      end
    end
    return segment_end[1] == :B ? reverse_segpath(list) : list
  end

  def sum_of_counts(segpath, multfactor = 1)
    retval = {}
    segs = segpath.map {|sn,et|segment!(sn)}
    [:KC, :RC, :FC].each do |count_tag|
      segs.each do |s|
        if s.optional_fieldnames.include?(count_tag)
          retval[count_tag] ||= 0
          retval[count_tag] += s.send(count_tag)
        end
      end
      if retval[count_tag]
        retval[count_tag] = (retval[count_tag] * multfactor).to_i
      end
    end
    return retval
  end

  def reverse_segment_name(name, separator)
    name.split(separator).map do |part|
      openp = part[0] == "("
      part = part[1..-1] if openp
      closep = part[-1] == ")"
      part = part[0..-2] if closep
      part = (part[-1] == "^") ? part[0..-2] : part+"^"
      part += ")" if openp
      part = "(#{part}" if closep
      part
    end.reverse.join(separator)
  end

  def reverse_pos_array(pos_array, lastpos)
    return nil if pos_array.nil? or lastpos.nil?
    pos_array.map {|pos| lastpos - pos + 1}.reverse
  end

  def add_segment_to_merged(merged, segment, reversed, cut, init, options)
    s = (reversed ? segment.sequence.rc[cut..-1] : segment.sequence[cut..-1])
    if init
      merged.sequence = s
      merged.name = (options[:merged_name].nil? ?
                     segment.name : options[:merged_name])
      merged.LN = segment.LN
    else
      (segment.sequence == "*") ? (merged.sequence = "*")
                                : (merged.sequence += s)
      merged.name += "_#{segment.name}" if options[:merged_name].nil?
      if merged.LN
        segment.LN ? merged.LN += (segment.LN - cut)
                   : merged.LN = nil
      end
    end
  end

  def create_merged_segment(segpath, options)
    merged = segment!(segpath.first.first).clone
    total_cut = 0
    a = segpath[0]
    first_reversed = (a[1] == :B)
    last_reversed = nil
    if options[:merged_name] == :short
      forbidden = (segment_names + path_names)
      options[:merged_name] = "merged1"
      while forbidden.include?(options[:merged_name])
        options[:merged_name] = options[:merged_name].next
      end
    end
    add_segment_to_merged(merged, segment!(a[0]), first_reversed, 0, true,
                          options)
    progress_log(:merge_linear_paths, 0.95) if @progress
    (segpath.size-1).times do |i|
      b = other_segment_end(segpath[i+1])
      l = link!(a, b)
      if l.overlap == "*"
        cut = 0
      elsif l.overlap.size == 1 and l.overlap[0][1] == "M"
        cut = l.overlap[0][0]
      else
        raise "Overlaps contaning other operations than M are not supported"
      end
      total_cut += cut
      last_reversed = (b[1] == :E)
      add_segment_to_merged(merged, segment!(b[0]), last_reversed, cut, false,
                            options)
      a = other_segment_end(b)
      if @progress
        progress_log(:merge_linear_paths, 0.45+(i/(segpath.size-1)))
      end
    end
    if merged.sequence != "*"
      if merged.LN.nil?
        merged.LN = merged.sequence.length
      elsif @validate and merged.LN != merged.sequence.length
        raise "Computed sequence length #{merged.sequence.length} "+
              "and computed LN #{merged.LN} differ"
      end
    end
    if merged.LN.nil?
      [:KC, :RC, :FC].each {|count_tag| merged.send(:"#{count_tag}=", nil)}
    else
      sum_of_counts(segpath, merged.LN.to_f / (total_cut+merged.LN)).
          each do |count_tag, count|
        merged.send(:"#{count_tag}=", count)
      end
    end
    return merged, first_reversed, last_reversed
  end

  def reverse_segpath(segpath)
    segpath.reverse.map {|segment_end| other_segment_end(segment_end)}
  end

  def link_merged(merged_name, segment_end, reversed)
    links_of(segment_end).each do |l|
      l2 = l.clone
      if l2.to == segment_end.first
        l2.to = merged_name
        if reversed
          l2.to_orient = GFA::Line.other_orientation(l2.to_orient)
        end
      else
        l2.from = merged_name
        if reversed
          l2.from_orient = GFA::Line.other_orientation(l2.from_orient)
        end
      end
      self << l2
    end
  end

end
