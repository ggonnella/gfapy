require_relative "error.rb"

#
# Methods for the RGFA class, which allow to modify the content of the graph
# without requiring complex graph traversal.
#
# @see RGFA::Traverse
#
module RGFA::Edit

  # Eliminate all sequences from S lines, changing them to a "*"
  #
  # @return [RGFA] self
  def delete_sequences
    @lines[:S].each {|l| l.sequence = "*"}
    self
  end

  # Eliminate all CIGAR from L/C/P lines, changing them to "*"
  #
  # @return [RGFA] self
  def delete_alignments
    @lines[:L].each {|l| l.overlap = "*"}
    @lines[:C].each {|l| l.overlap = "*"}
    @lines[:P].each {|l| l.cigars = Array.new(l.cigars.size){"*"}}
    self
  end

  # Rename a segment or a path
  #
  # @param old_name [String] the name of the segment or path to rename
  # @param new_name [String] the new name for the segment or path
  #
  # @raise[RGFA::DuplicatedLabelError]
  #   if +new_name+ is already a segment or path name
  # @return [RGFA] self
  def rename(old_name, new_name)
    old_name = old_name.to_sym
    new_name = new_name.to_sym
    validate_segment_and_path_name_unique!(new_name)
    is_path = @path_names.has_key?(old_name.to_sym)
    is_segment = @segment_names.has_key?(old_name.to_sym)
    if !is_path and !is_segment
      raise RGFA::DuplicatedLabelError,
        "#{old_name} is not a path or segment name"
    end
    if is_segment
      s = segment!(old_name)
      s.name = new_name
      i = @segment_names[old_name.to_sym]
      @segment_names.delete(old_name.to_sym)
      @segment_names[new_name.to_sym] = i
      [:L,:C].each do |rt|
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
      i = @path_names[old_name.to_sym]
      pt.name = new_name
      @path_names.delete(old_name.to_sym)
      @path_names[new_name.to_sym] = i
    end
    self
  end

  # Create multiple copies of a segment.
  #
  # <b>Automatic computation of the copy names:</b>
  #
  # - Can be overridden, by providing an array of copy names.
  # - First, itis checked if the name of the original segment ends with a
  #   relevant
  #   string, i.e. a lower case letter (for +:lowcase+), an upper case letter
  #   (for +:upcase+), a digit (for +:number+), or the string +"_copy"+
  #   plus one or more optional digits (for +:copy+).
  # - If so, it is assumed, it was already a copy, and it is not
  #   altered.
  # - If not, then +a+ (for +:lowcase+), +A+ (for +:upcase+), +1+ (for
  #   +:number+), +_copy+ (for +:copy+) is appended to the string.
  # - Then, in all
  #   cases, next (*) is called on the string, until a valid, non-existant name
  #   is found for each of the segment copies
  # - (*) = except for +:copy+, where
  #   for the first copy no digit is present, but for the following is,
  #   i.e. the segment names will be +:copy+, +:copy2+, +:copy3+, etc.
  #
  # @param [Integer] factor multiplication factor; if 0, delete the segment;
  #   if 1; do nothing; if > 1; number of copies to create
  # @param segment [String, RGFA::Line::Segment] segment name or instance
  # @param [:lowcase, :upcase, :number, :copy, Array<String>] copy_names
  #   <i>(Defaults to: +:lowcase+)</i>
  #   Array of names for the copies of the segment,
  #   or a symbol, which defines a system to compute the names from the name of
  #   the original segment. See "automatic computation of the copy names".
  # @param [Boolean] conserve_components <i>(Defaults to: +true+)</i>
  #   If factor == 0 (i.e. deletion), delete segment only if
  #   {#cut_segment?}(segment) is +false+.
  #
  # @return [RGFA] self
  def multiply(segment, factor, copy_names: :lowcase,
               conserve_components: true)
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment
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

  private

  def compute_copy_names(copy_names, segment_name, factor)
    return nil if factor < 2
    accepted = [:lowcase, :upcase, :number, :copy]
    if copy_names.kind_of?(Array)
      return copy_names
    elsif !accepted.include?(copy_names)
      raise ArgumentError,
        "copy_names shall be an array of names or one of: "+
        accepted.inspect
    end
    retval = []
    next_name = segment_name.to_s
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
            @segment_names.has_key?(next_name.to_sym) or
            @path_names.has_key?(next_name.to_sym)
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
    [:L,:C].each do |rt|
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
    [:L,:C].each do |rt|
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
