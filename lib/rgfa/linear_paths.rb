require_relative "segment_ends_path"

#
# Methods for the RGFA class, which allow to find and merge linear paths.
#
module RGFA::LinearPaths

  require "set"

  # @return [Array<RGFA::SegmentEnd>]
  #
  # Find an eventual path without branches which
  #   includes +segment+ and excludes segments in +exclude+.
  # Any segment used in the returned path will be added to +exclude+
  #
  # @param s [String|RGFA::Line::Segment] a segment name or instance
  # @param exclude [Set<String>] a set of segment names to exclude from the path
  #
  def linear_path(s, exclude = Set.new)
    s = s.to_sym
    cs = connectivity(s)
    segpath = RGFA::SegmentEndsPath.new()
    [:B, :E].each_with_index do |et, i|
      if cs[i] == 1
        exclude << s
        segpath.pop
        segpath += traverse_linear_path(RGFA::SegmentEnd.new([s, et]), exclude)
      end
    end
    return (segpath.size < 2) ? nil : segpath
  end

  # Find all unbranched paths of segments connected by links in the graph.
  #
  # @return [Array<Array<RGFA::SegmentEnd>>]
  def linear_paths
    exclude = Set.new
    retval = []
    segnames = segment_names
    progress_log_init(:linear_paths, "segments", segnames.size,
      "Detect linear paths (#{segnames.size} segments)")  if @progress
    segnames.each do |sn|
      progress_log(:linear_paths) if @progress
      next if exclude.include?(sn)
      retval << linear_path(sn, exclude)
    end
    progress_log_end(:linear_paths)
    return retval.compact
  end

  # Merge a linear path, i.e. a path of segments without extra-branches
  # @!macro [new] merge_lim
  #   Limitations: all containments und paths involving merged segments are
  #   deleted.
  #
  # @param segpath [Array<RGFA::SegmentEnd>] a linear path, such as that
  #   retrieved by {#linear_path}
  # @!macro [new] merge_options
  #   @param options [Hash] optional keyword arguments
  #   @option options [String, :short, nil] :merged_name (nil)
  #     if nil, the merged_name is automatically computed; if :short,
  #     a name is computed starting with "merged1" and calling next until
  #     an available name is founf; if String, the name to use
  #   @option options [Boolean] :cut_counts (false)
  #     if true, total count in merged segment m, composed of segments
  #     s of set S is multiplied by the factor Sum(|s in S|)/|m|
  #
  # @return [RGFA] self
  # @see #merge_linear_paths
  def merge_linear_path(segpath, **options)
    return if segpath.size < 2
    segpath.map!{|se|se.to_segment_end}
    if segpath[1..-2].any? {|sn,et| connectivity(sn) != [1,1]}
      raise ArgumentError, "The specified path is not linear"
    end
    merged, first_reversed, last_reversed =
      create_merged_segment(segpath, options)
    self << merged
    link_merged(merged.name, segpath.first.to_segment_end.invert_end_type,
                first_reversed)
    link_merged(merged.name, segpath.last, last_reversed)
    segpath.each do |sn_et|
      delete_segment(sn_et.segment)
      progress_log(:merge_linear_paths, 0.05) if @progress
    end
    self
  end

  # Merge all linear paths in the graph, i.e.
  # paths of segments without extra-branches
  # @!macro merge_lim
  # @!macro merge_options
  #
  # @return [RGFA] self
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

  private

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
    list = RGFA::SegmentEndsPath.new()
    current = segment_end
    loop do
      after  = links_of(current)
      before = links_of(current.to_segment_end.invert_end_type)
      cs = connectivity_symbols(before.size, after.size)
      if cs == [1,1] or list.empty?
        list << current
        exclude << current.name
        l = after.first
        current = l.other_end(current).invert_end_type
        break if exclude.include?(current.name)
      elsif cs[0] == 1
        list << current
        exclude << current.name
        break
      else
        break
      end
    end
    return segment_end.end_type == :B ? list.reverse : list
  end

  def sum_of_counts(segpath, multfactor = 1)
    retval = {}
    segs = segpath.map {|sn,et|segment!(sn)}
    [:KC, :RC, :FC].each do |count_tag|
      segs.each do |s|
        if s.optional_fieldnames.include?(count_tag)
          retval[count_tag] ||= 0
          retval[count_tag] += s.get(count_tag)
        end
      end
      if retval[count_tag]
        retval[count_tag] = (retval[count_tag] * multfactor).to_i
      end
    end
    return retval
  end

  def reverse_segment_name(name, separator)
    name.to_s.split(separator).map do |part|
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
      if options[:merged_name].nil?
        merged.name = "#{merged.name}_#{segment.name}"
      end
      if merged.LN
        segment.LN ? merged.LN += (segment.LN - cut)
                   : merged.LN = nil
      end
    end
  end

  def create_merged_segment(segpath, options)
    merged = segment!(segpath.first.first).clone
    total_cut = 0
    a = segpath.first
    first_reversed = (a.end_type == :B)
    last_reversed = nil
    if options[:merged_name] == :short
      forbidden = (segment_names + path_names)
      options[:merged_name] = "merged1"
      while forbidden.include?(options[:merged_name])
        options[:merged_name] = options[:merged_name].next
      end
    end
    add_segment_to_merged(merged, segment(a.segment), first_reversed, 0, true,
                          options)
    progress_log(:merge_linear_paths, 0.95) if @progress
    (segpath.size-1).times do |i|
      b = segpath[i+1].to_segment_end.invert_end_type
      l = link!(a, b)
      if l.overlap == []
        cut = 0
      elsif l.overlap.all?{|op|[:M, :"="].include?(op.code)}
        cut = l.overlap.map(&:len).inject(:+)
      else
        raise ArgumentError,
          "Merging is only allowed if all operations are M/="
      end
      total_cut += cut
      last_reversed = (b[1] == :E)
      add_segment_to_merged(merged, segment(b.segment), last_reversed, cut,
                            false, options)
      a = b.to_segment_end.invert_end_type
      if @progress
        progress_log(:merge_linear_paths, 0.95)
      end
    end
    if merged.sequence != "*"
      if merged.LN.nil?
        merged.LN = merged.sequence.length
      elsif @validate and merged.LN != merged.sequence.length
        raise RGFA::Line::Segment::InconsistentLengthError,
              "Computed sequence length #{merged.sequence.length} "+
              "and computed LN #{merged.LN} differ"
      end
    end
    if merged.LN.nil?
      [:KC, :RC, :FC].each {|count_tag| merged.set(count_tag, nil)}
    else
      sum_of_counts(segpath, (options[:cut_counts] ?
                              merged.LN.to_f / (total_cut+merged.LN) : 1)).
          each do |count_tag, count|
        merged.set(count_tag, count)
      end
    end
    return merged, first_reversed, last_reversed
  end

  def link_merged(merged_name, segment_end, reversed)
    links_of(segment_end).each do |l|
      l2 = l.clone
      if l2.to == segment_end.first
        l2.to = merged_name
        if reversed
          l2.to_orient = RGFA::OrientedSegment.invert(l2.to_orient)
        end
      else
        l2.from = merged_name
        if reversed
          l2.from_orient = RGFA::OrientedSegment.invert(l2.from_orient)
        end
      end
      self << l2
    end
  end

end
