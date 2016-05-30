#
# Methods for the GFA class, which allow to change the content of the graph
#
module GFA::Edit

  # Eliminate the sequences from S lines
  def delete_sequences
    @lines["S"].each {|l| l.sequence = "*"}
    self
  end

  # Eliminate the CIGAR from L/C/P lines
  def delete_alignments
    @lines["L"].each {|l| l.overlap = "*"}
    @lines["C"].each {|l| l.overlap = "*"}
    @lines["P"].each {|l| l.cigars = "*"}
    self
  end

  def rename_segment(segment_name, new_name)
    validate_segment_and_path_name_unique!(new_name)
    s = segment!(segment_name)
    s.name = new_name
    i = @segment_names.index(segment_name)
    @segment_names[i] = new_name
    ["L","C"].each do |rt|
      [:from,:to].each do |dir|
        @c.lines(rt, segment_name, dir).each do |l|
          l.send(:"#{dir}=", new_name)
        end
      end
    end
    paths_with(segment_name).each do |l|
      l.segment_names = l.segment_names.map do |sn, o|
        sn = new_name if sn == segment_name
        [sn, o].join("")
      end.join(",")
    end
    @c.rename_segment(segment_name, new_name)
    self
  end

  def multiply_segment(segment_name, factor, copy_names: :lowcase,
                       links_distribution_policy: :auto,
                       origin_tag: :or)
    if factor < 2
      return factor == 1 ? self : delete_segment(segment_name)
    end
    s = segment(segment_name)
    s.send(:"#{origin_tag}=", s.name) if !s.send(origin_tag)
    divide_segment_and_connection_counts(s, factor)
    copy_names = compute_copy_names(copy_names, segment_name, factor)
    copy_names.each {|cn| clone_segment_and_connections(s, cn)}
    distribute_links(links_distribution_policy, segment_name, copy_names,
                     factor)
    return self
  end

  def duplicate_segment(segment_name, copy_name: :lowcase,
                       links_distribution_policy: :auto,
                       origin_tag: :or)
    multiply_segment(segment_name, 2,
                     copy_names:
                       copy_name.kind_of?(String) ? [copy_name] : copy_name,
                     links_distribution_policy: links_distribution_policy,
                     origin_tag: origin_tag)
  end

  def delete_low_coverage_segments(mincov, count_tag: :RC)
    segments.map do |s|
      cov = s.coverage(count_tag: count_tag)
      cov < mincov ? s.name : nil
    end.compact.each do |sn|
      delete_segment(sn)
    end
    self
  end

  def mean_coverage(segment_names, count_tag: :RC)
    count = 0
    length = 0
    segment_names.each do |s|
      s = segment!(s)
      c = s.send(count_tag)
      raise "Tag #{count_tag} not available for segment #{s.name}" if c.nil?
      l = s.LN
      raise "Tag LN not available for segment #{s.name}" if l.nil?
      count += c
      length += l
    end
    count.to_f/length
  end

  def compute_copy_numbers(single_copy_coverage, count_tag: :RC, tag: :cn)
    segments.each do |s|
      s.send(:"#{tag}=", (s.coverage!(count_tag:
               count_tag).to_f / single_copy_coverage).round)
    end
    self
  end

  def apply_copy_numbers(tag: :cn, links_distribution_policy: :auto,
                         copy_names_suffix: :lowcase, origin_tag: :or)
    segments.sort_by{|s|s.send(:"#{tag}!")}.each do |s|
      multiply_segment(s.name, s.send(tag),
                       links_distribution_policy: links_distribution_policy,
                       copy_names: copy_names_suffix,
                       origin_tag: origin_tag)
    end
    self
  end

  def select_random_orientation
    segments.each do |s|
      if segment_same_links_both_ends?(s.name)
        parts = partitioned_links_of([s.name, :E])
        if parts.size == 2
          tokeep1_other_end = parts[0][0].other_end([s.name, :E])
          tokeep2_other_end = parts[1][0].other_end([s.name, :E])
        elsif parts.size == 1 and parts[0].size == 2
          tokeep1_other_end = parts[0][0].other_end([s.name, :E])
          tokeep2_other_end = parts[0][1].other_end([s.name, :E])
        else
          next
        end
        next if links_of(tokeep1_other_end).size < 2
        next if links_of(tokeep2_other_end).size < 2
        STDERR.puts "Random orientation points: "+
          "#{tokeep2_other_end.join(":")}"+
          "-*-B:#{s.name}:E-*-"+
          "#{tokeep1_other_end.join(":")}"
        delete_other_links([s.name, :E], tokeep1_other_end)
        delete_other_links([s.name, :B], tokeep2_other_end)
      end
    end
  end

  def enforce_single_edges
    segments.each do |s|
      se = {}
      l = {}
      [:B, :E].each do |et|
        se[et] = [s.name, et]
        l[et] = links_of(se[et])
      end
      cs = connectivity_symbols(l[:B].size, l[:E].size)
      if cs == [1, 1]
        oe = {}
        [:B, :E].each {|et| oe[et] = l[et][0].other_end(se[et])}
        next if oe[:B] == oe[:E]
        [:B, :E].each {|et| delete_other_links(oe[et], se[et])}
      else
        i = cs.index(1)
        next if i.nil?
        et = [:B, :E][i]
        oe = l[et][0].other_end(se[et])
        delete_other_links(oe, se[et])
      end
    end
  end

  private

  def compute_copy_names(copy_names, segment_name, factor)
    accepted = [:lowcase, :upcase, :number, :copy]
    if copy_names.kind_of?(Array)
      return copy_names
    elsif !accepted.include?(copy_names)
      raise "copy_names shall be an array of names or one of: "+
        accepted.inspect
    end
    retval = []
    next_name = segment_name
    case copy_names
    when :lowcase
      if next_name =~ /^.*[a-z]$/
        next_name = next_name.next
      else
        next_name += "b"
      end
    when :upcase
      if next_name =~ /^.*[A-Z]$/
        next_name = next_name.next
      else
        next_name += "B"
      end
    when :number
      if next_name =~ /^.*[0-9]$/
        next_name = next_name.next
      else
        next_name += "2"
      end
    when :copy
      if next_name =~ /^.*_copy(\d*)$/
        next_name += "1" if $1 == ""
        next_name = next_name.next
        copy_names = :number
      else
        next_name += "_copy"
      end
    end
    while retval.size < (factor-1)
      while retval.include?(next_name) or
            @segment_names.include?(next_name) or
            @path_names.include?(next_name)
        if copy_names == :copy
          next_name += "1"
          copy_names = :number
        end
        next_name = next_name.next
      end
      retval << next_name
    end
    return retval
  end

  def divide_counts(gfa_line, factor)
    [:KC, :RC, :FC].each do |count_tag|
      if gfa_line.optional_fieldnames.include?(count_tag)
        value = (gfa_line.send(count_tag).to_f / factor)
        gfa_line.send(:"#{count_tag}=", value.to_i.to_s)
      end
    end
  end

  def divide_segment_and_connection_counts(segment, factor)
    divide_counts(segment, factor)
    ["L","C"].each do |rt|
      [:from,:to].each do |dir|
        @c.lines(rt,segment.name,dir).each do |l|
          # circular link counts shall be divided only ones
          next if dir == :to and l.from == l.to
          divide_counts(l, factor)
        end
      end
    end
  end

  def clone_segment_and_connections(segment, clone_name)
    cpy = segment.clone
    cpy.name = clone_name
    self << cpy
    ["L","C"].each do |rt|
      [:from,:to].each do |dir|
        @c.lines(rt,segment.name,dir).each do |l|
          lc = l.clone
          lc.send(:"#{dir}=", clone_name)
          self << lc
        end
      end
    end
  end

  def select_distribute_end(links_distribution_policy, segment_name, factor)
    accepted = [:off, :auto, :equal, :E, :B]
    if !accepted.include?(links_distribution_policy)
      raise "Unknown links_distribution_policy, accepted values are: "+
        accepted.inspect
    end
    return nil if links_distribution_policy == :off
    if [:B, :E].include?(links_distribution_policy)
      return links_distribution_policy
    end
    esize = links_of([segment_name, :E]).size
    bsize = links_of([segment_name, :B]).size
    if esize == factor
      return :E
    elsif bsize == factor
      return :B
    elsif links_distribution_policy == :equal
      return nil
    elsif esize < 2
      return (bsize < 2) ? nil : :B
    elsif bsize < 2
      return :E
    elsif esize < factor
      return ((bsize <= esize) ? :E :
        ((bsize < factor) ? :B : :E))
    elsif bsize < factor
      return :B
    else
      return ((bsize <= esize) ? :B : :E)
    end
  end

  def distribute_links(links_distribution_policy, segment_name,
                       copy_names, factor)
    end_type = select_distribute_end(links_distribution_policy,
                                     segment_name, factor)
    return nil if end_type.nil?
    et_links = links_of([segment_name, end_type])
    diff = [et_links.size - factor, 0].max
    links_signatures = et_links.map do |l|
      l.other_end([segment_name, end_type]).join
    end
    ([segment_name]+copy_names).each_with_index do |sn, i|
      links_of([sn, end_type]).each do |l|
        l_sig = l.other_end([sn, end_type]).join
        to_save = links_signatures[i..i+diff].to_a
        delete_link_line(l) unless to_save.include?(l_sig)
      end
    end
  end

  def link_targets_for_cmp(segment_end)
    links_of(segment_end).map {|l| l.other_end(segment_end).join}
  end

  def segment_same_links_both_ends?(segment_name)
    e_links = link_targets_for_cmp([segment_name, :E])
    b_links = link_targets_for_cmp([segment_name, :B])
    return e_links == b_links
  end

  def segments_same_links?(segment_names)
    raise if segment_names.size < 2
    e_links_first = link_targets_for_cmp([segment_names.first, :E])
    b_links_first = link_targets_for_cmp([segment_names.first, :B])
    return segment_names[1..-1].all? do |sn|
      (link_targets_for_cmp([sn, :E]) == e_links_first) and
      (link_targets_for_cmp([sn, :B]) == b_links_first)
    end
  end

  def segment_signature(segment_end)
    s = segment!(segment_end[0])
    link_targets_for_cmp(segment_end).join(",")+"\t"+
    link_targets_for_cmp(other_segment_end(segment_end)).join(",")+"\t"+
    [:or, :coverage].map do |field|
      s.send(field)
    end.join("\t")
  end

  def segments_equivalent?(segment_names)
    raise if segment_names.size < 2
    segments = segment_names.map{|sn|segment!(sn)}
    [:or, :coverage].each do |field|
      if segments.any?{|s|s.send(field) != segments.first.send(field)}
        return false
      end
    end
    return segment_same_links?(segment_names)
  end

  def partitioned_links_of(segment_end)
    links_of(segment_end).group_by do |l|
      other_end = l.other_end(segment_end)
      sig = segment_signature(other_end)
      sig
    end.map {|sig, par| par}
  end

end
