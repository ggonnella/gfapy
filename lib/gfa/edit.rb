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

  def rename(old_name, new_name)
    validate_segment_and_path_name_unique!(new_name)
    is_path = @path_names.include?(old_name)
    is_segment = @segment_names.include?(old_name)
    if !is_path and !is_segment
      raise "#{old_name} is not a path or segment name"
    end
    if is_segment
      s = segment!(old_name)
      s.name = new_name
      i = @segment_names.index(old_name)
      @segment_names[i] = new_name
      ["L","C"].each do |rt|
        [:from,:to].each do |dir|
          @c.lines(rt, old_name, dir).each do |l|
            l.send(:"#{dir}=", new_name)
          end
        end
      end
      paths_with(old_name).each do |l|
        l.segment_names = l.segment_names.map do |sn, o|
          sn = new_name if sn == old_name
          [sn, o].join("")
        end.join(",")
      end
      @c.rename_segment(old_name, new_name)
    else
      pt = path!(old_name)
      i = @path_names.index(old_name)
      pt.name = new_name
      @path_names[i] = new_name
    end
    self
  end

  def multiply(segment_name, factor, copy_names: :lowcase,
               conserve_components: true)
    segment_name = segment_name.name if segment_name.kind_of?(GFA::Line)
    if factor < 2
      return self if factor == 1
      return self if cut_segment?(segment_name) and conserve_components
      return delete_segment(segment_name)
    end
    s = segment!(segment_name)
    divide_segment_and_connection_counts(s, factor)
    copy_names = compute_copy_names(copy_names, segment_name, factor)
    copy_names.each {|cn| clone_segment_and_connections(s, cn)}
    return self
  end

  def duplicate(segment_name, copy_name: :lowcase)
    multiply(segment_name, 2,
             copy_names: copy_name.kind_of?(String) ? [copy_name] : copy_name)
  end

  def mean_coverage(segment_names, count_tag: :RC)
    count = 0
    length = 0
    segment_names.each do |s|
      s = segment!(s)
      c = s.send(count_tag)
      raise "Tag #{count_tag} not available for segment #{s.name}" if c.nil?
      l = s.LN
      if l.nil?
        if s.sequence != "*"
          l = s.sequence.size
        else
          raise "Sequence is empty and tag LN is not available:\n"+
            "Cannot compute coverage for segment #{s.name}"
        end
      end
      count += c
      length += l
    end
    count.to_f/length
  end

  private

  def compute_copy_names(copy_names, segment_name, factor)
    return nil if factor < 2
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

end
