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

end
