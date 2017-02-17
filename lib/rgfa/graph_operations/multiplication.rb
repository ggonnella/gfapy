require_relative "../error.rb"

#
# Method for the RGFA class, which allow to split a segment into
# multiple copies.
#
# @tested_in api_multiplication
#
module RGFA::GraphOperations::Multiplication

  # Create multiple copies of a segment.
  #
  # == Automatic computation of the copy names
  #
  # - Can be overridden, by providing an array of copy names.
  # - First, it is checked if the name of the original segment ends with a
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
  def multiply(segment, factor, copy_names: :asterisk,
               conserve_components: true)
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment
    if factor < 2
      return self if factor == 1
      return self if cut_segment?(segment_name) and conserve_components
      return rm(segment_name)
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
    accepted = [:lowcase, :upcase, :number, :copy, :asterisk]
    if copy_names.kind_of?(Array)
      return copy_names
    elsif !accepted.include?(copy_names)
      raise RGFA::ArgumentError,
        "copy_names shall be an array of names or one of: "+
        accepted.inspect
    end
    retval = []
    next_name = segment_name.to_s
    case copy_names
    when :asterisk
      if next_name =~ /^(.)\*\d+$/
        next_name = next_name.next
      else
        next_name += "*2"
      end
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
            line(next_name.to_sym)
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
      if gfa_line.tagnames.include?(count_tag)
        value = (gfa_line.get(count_tag).to_f / factor)
        gfa_line.set(count_tag, value.to_i)
      end
    end
  end

  def divide_segment_and_connection_counts(segment, factor)
    divide_counts(segment, factor)
    processed_circulars = Set.new
    (segment.dovetails + segment.containments).each do |l|
      # circular link counts shall be divided only ones
      if !l.circular? or !processed_circular.include?(l)
        divide_counts(l, factor)
        processed_circulars << l if l.circular?
      end
    end
  end

  def clone_segment_and_connections(segment, clone_name)
    cpy = segment.clone
    cpy.name = clone_name
    cpy.connect(self)
    (segment.dovetails + segment.containments).each do |l|
      lc = l.clone
      lc.from = clone_name if lc.from == segment.name
      lc.to = clone_name if lc.to == segment.name
      lc.connect(self)
    end
  end

end
