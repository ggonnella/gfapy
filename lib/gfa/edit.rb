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
        connection_lines(rt, dir, segment_name).each do |l|
          l.send(:"#{dir}=", new_name)
        end
      end
    end
    connect_rename_segment(segment_name, new_name)
    if @paths_with.has_key?(segment_name)
      paths_with(segment_name).each do |l|
        l.segment_names = l.segment_names.map do |sn, o|
          sn = new_name if sn == segment_name
          [sn, o].join("")
        end.join(",")
      end
      @paths_with[new_name] = @paths_with[segment_name]
      @paths_with.delete(segment_name)
    end
    self
  end

  def multiply_segment(segment_name, factor, copy_names: nil,
                       distribute_links: [])
    raise ArgumentError, "Factor must be >= 2: #{factor} found" if factor < 2
    if copy_names.nil?
      copy_names = ["#{segment_name}_copy"]
      (factor-2).times {|i| copy_names << "#{segment_name}_copy#{i+2}"}
    end
    s = segment(segment_name)
    s.or = s.name if !s.or
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
      cpy.or = s.or
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
    distribute_links.each do |end_type|
      et_links = links_of(segment_name, end_type)
      diff = [et_links.size - factor, 0].max
      links_signatures = et_links.map do |l|
        l.other(segment_name) + l.other_end_type(segment_name).to_s
      end
      ([segment_name]+copy_names).each_with_index do |sn, i|
        links_of(sn, end_type).each do |l|
          l_sig = l.other(sn)+l.other_end_type(sn).to_s
          to_save = links_signatures[i..i+diff].to_a
          delete_link_line(l) unless to_save.include?(l_sig)
        end
      end
    end
    return self
  end

  def duplicate_segment(segment_name, copy_name: nil)
    multiply_segment(segment_name, 2,
                     copy_names: copy_name.nil? ? nil : [copy_name])
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

  def apply_copy_numbers(tag: :cn)
    segments.sort_by{|s|s.cn}.each do |s|
      case s.cn!
      when 0
        delete_segment(s.name)
      when 1
        next
      else
        esize = links_of(s.name, :E).size
        bsize = links_of(s.name, :B).size
        if esize == s.cn
          distribute = [:E]
        elsif bsize == s.cn
          distribute = [:B]
        elsif esize == 0
          distribute = (bsize == 0) ? [] : [:B]
        elsif bsize == 0
          distribute = [:E]
        elsif esize < s.cn
          distribute = (bsize <= esize) ? [:E] :
             ((bsize < cn) ? [:B] : [:E])
        elsif bsize < s.cn
          distribute = [:B]
        else
          distribute = (bsize <= esize) ? [:B] : [:E]
        end
        multiply_segment(s.name, s.cn, distribute_links: distribute)
      end
    end
    self
  end

  def select_random_orientation
    segments.each do |s|
      if segment_same_links_both_ends?(s.name)
        parts = {}
        parts[:E] = partitioned_links_of(s.name, :E)
        if parts[:E].size == 2
          parts[:B] = partitioned_links_of(s.name, :B)
          if segment_signature(parts[:B][0][0].other(s.name)) !=
             segment_signature(parts[:E][0][0].other(s.name))
            parts[:B].reverse!
          end
          [:E, :B].each_with_index do |e, i|
            links_of(s.name, e).each do |l|
              delete_link_line(l) if l != parts[e][i][0]
            end
          end
        end
      end
    end
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

  def link_targets_for_cmp(segment_name, end_type)
    links_of(segment_name, end_type).map do |l|
      l.other(segment_name)+l.other_end_type(segment_name).to_s
    end.sort
  end

  def segment_same_links_both_ends?(segment_name)
    e_links = link_targets_for_cmp(segment_name, :E)
    b_links = link_targets_for_cmp(segment_name, :B)
    return e_links == b_links
  end

  def segments_same_links?(segment_names)
    raise if segment_names.size < 2
    e_links_first = link_targets_for_cmp(segment_names.first, :E)
    b_links_first = link_targets_for_cmp(segment_names.first, :B)
    return segment_names[1..-1].all? do |sn|
      (link_targets_for_cmp(sn, :E) == e_links_first) and
      (link_targets_for_cmp(sn, :B) == b_links_first)
    end
  end

  def segment_signature(segment_name)
    s = segment!(segment_name)
    link_targets_for_cmp(segment_name, :B).join(",")+"\t"+
    link_targets_for_cmp(segment_name, :E).join(",")+"\t"+
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

  def partitioned_links_of(segment_name, end_type)
    links_of(segment_name, end_type).group_by do |l|
      segment_signature(l.other(segment_name))
    end.map {|sig, par| par}
  end

end
