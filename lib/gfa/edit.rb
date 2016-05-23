#
# Methods for the GFA class, which allow to change the content of the graph
#
module GFA::Edit

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

  # TODO: remove the ! from the editing methods

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

  def delete_low_coverage_segments!(mincov, count_tag: :RC)
    segments.map do |s|
      cov = s.coverage!(count_tag: count_tag)
      cov < mincov ? s.name : nil
    end.compact.each do |sn|
      delete_segment!(sn)
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
    segments.each do |s|
      case s.cn!
      when 0
        delete_segment!(s.name)
      when 1
        next
      else
        new_names = ["#{s.name}_copy"]
        (s.cn-2).times {|i| new_names << "#{s.name}_copy#{i+2}"}
        multiply_segment!(s.name, new_names)
      end
    end
    self
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

end
