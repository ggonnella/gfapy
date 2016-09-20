#
# Methods for the RGFA class, which involve a traversal of the graph following
# links
#
module RGFATools::LinearPaths

  # @!method merge_linear_path(segpath, **options)
  #   Merge a linear path, i.e. a path of segments without extra-branches.
  #   @!macro [new] merge_more
  #     Extends the RGFA method, with additional functionality:
  #     - +name+: the name of the merged segment is set to the name of the
  #       single segments joined by underscore (+_+). If a name already
  #       contained an underscore, it is splitted before merging. Whenever a
  #       segment is reversed complemented, its name (or the name of all its
  #       components) is suffixed with a +^+; if the last letter was already
  #       +^+, it is removed; if it contained +_+ the name is splitted, the
  #       elements reversed and joined back using +_+; round parentheses are
  #       removed from the name before processing and added back after it.
  #     - +:or+: keeps track of the origin of the merged segment; the
  #       origin tag is set to an array of :or or name
  #       (if no :or available) tags of the segment which have been merged;
  #       the character +^+ is assigned the same meaning as in +name+
  #     - +:rn+: tag used to store possible inversion positions and
  #       it is updated by this method; i.e. it is passed from the single
  #       segments to the merged segment, and the coordinates updated
  #     - +:mp+: tag used to store the position of the
  #       single segments in the merged segment; it is created or updated by
  #       this method
  #     Note that the extensions to the original method will only be run
  #     if either #enable_extensions has been called on RGFA object
  #     or the enable_tracking parameter is set..
  #     After calling #enable_extensions, you may still obtain the original
  #     behaviour by setting the disable_tracking parameter.
  #   @!macro merge_more
  #
  #   @!macro [new] merge_lim
  #
  #     Limitations: all containments und paths involving merged segments are
  #     deleted.
  #   @!macro merge_lim
  #
  #   @param segpath [Array<RGFA::SegmentEnd>] a linear path, such as that
  #     retrieved by #linear_path (see RGFA API documentation)
  #   @!macro [new] merge_options
  #     @param options [Hash] optional keyword arguments
  #     @option options [String, :short, nil] :merged_name (nil)
  #       if nil, the merged_name is automatically computed; if :short,
  #       a name is computed starting with "merged1" and calling next until
  #       an available name is founf; if String, the name to use
  #     @option options [Boolean] :cut_counts (false)
  #       if true, total count in merged segment m, composed of segments
  #       s of set S is multiplied by the factor Sum(|s in S|)/|m|
  #     @option options [Boolean] :enable_tracking (false)
  #       if true, the extended method with RGFATools is called,
  #       no matter if RGFA#enable_extensions was called.
  #     @option options [Boolean] :disable_tracking (false)
  #       if true, the original method of RGFA without RGFATools is called,
  #       no matter if RGFA#enable_extensions was called.
  #   @!macro merge_options
  #
  #   @return [RGFA] self
  #   @see #merge_linear_paths

  # @!method merge_linear_paths(**options)
  #   Merge all linear paths in the graph, i.e.
  #   paths of segments without extra-branches
  #   @!macro merge_more
  #   @!macro merge_lim
  #   @!macro merge_options
  #
  #   @return [RGFA] self

  private

  Redefined = [:add_segment_to_merged]

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

  def add_segment_to_merged_with_rgfatools(merged, segment, reversed, cut, init,
                                          options)
    if !options[:enable_tracking] and
        (options[:disable_tracking] or !@extensions_enabled)
      return add_segment_to_merged_without_rgfatools(merged, segment, reversed,
                                                    cut, init, options)
    end
    s = (reversed ? segment.sequence.rc[cut..-1] : segment.sequence[cut..-1])
    n = (reversed ? reverse_segment_name(segment.name, "_") : segment.name.to_s)
    rn = (reversed ? reverse_pos_array(segment.rn, segment.LN) : segment.rn)
    mp = (reversed ? reverse_pos_array(segment.mp, segment.LN) : segment.mp)
    mp = [1, segment.LN] if mp.nil? and segment.LN
    if segment.or.nil?
      o = n
    else
      o = (reversed ? reverse_segment_name(segment.or, ",") : segment.or)
    end
    if init
      merged.sequence = s
      merged.name = options[:merged_name].nil? ? n : options[:merged_name]
      merged.LN = segment.LN
      merged.rn = rn
      merged.or = o
      merged.mp = mp
    else
      (segment.sequence == "*") ? (merged.sequence = "*")
                                : (merged.sequence += s)
      merged.name = "#{merged.name}_#{n}" if options[:merged_name].nil?
      if merged.LN
        if rn
          rn = rn.map {|pos| pos - cut + merged.LN}
          merged.rn = merged.rn.nil? ? rn : merged.rn + rn
        end
        if mp and merged.mp
          merged.mp += mp.map {|pos| pos - cut + merged.LN}
        end
        segment.LN ? merged.LN += (segment.LN - cut)
                   : merged.LN = nil
      else
        merged.mp = nil
      end
      merged.or = merged.or.nil? ? o : "#{merged.or},#{o}"
    end
  end

end
