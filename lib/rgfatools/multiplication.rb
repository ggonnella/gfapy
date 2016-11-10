#
# Methods which edit the graph components without traversal
#
module RGFATools::Multiplication

  # Allowed values for the links_distribution_policy option
  LINKS_DISTRIBUTION_POLICY = [:off, :auto, :equal, :E, :B]

  # @overload multiply(segment, factor, copy_names: :lowcase, distribute: :auto, conserve_components: true, origin_tag: :or)
  # Create multiple copies of a segment.
  #
  # Complements the multiply method of gfatools with additional functionality.
  # These extensions are used only after #enable_extensions is called on the
  # RGFA object. After that, you may still call the original method
  # using #multiply_without_rgfatools.
  #
  # For more information on the additional functionality, see
  # #multiply_extended.
  #
  # @return [RGFA] self
  def multiply_with_rgfatools(segment, factor,
                       copy_names: :lowcase,
                       distribute: :auto,
                       conserve_components: true,
                       origin_tag: :or)
    if !@extensions_enabled
      return multiply_without_rgfatools(segment, factor,
                       copy_names: copy_names,
                       conserve_components: conserve_components)
    else
      multiply_extended(segment, factor,
                       copy_names: copy_names,
                       distribute: distribute,
                       conserve_components: conserve_components,
                       origin_tag: origin_tag)
    end
  end

  # Create multiple copies of a segment.
  #
  # Complements the multiply method of gfatools with additional functionality.
  # To always run the additional functionality when multiply is called,
  # use RGFA#enable_extensions.
  #
  # @!macro [new] copynames_text
  #
  #   <b>Automatic computation of the copy names:</b>
  #
  #   - First, itis checked if the name of the original segment ends with a
  #     relevant
  #     string, i.e. a lower case letter (for +:lowcase+), an upper case letter
  #     (for +:upcase+), a digit (for +:number+), or the string +"_copy"+
  #     plus one or more optional digits (for +:copy+).
  #   - If so, it is assumed, it was already a copy, and it is not
  #     altered.
  #   - If not, then +a+ (for +:lowcase+), +A+ (for +:upcase+), +1+ (for
  #     +:number+), +_copy+ (for +:copy+) is appended to the string.
  #   - Then, in all
  #     cases, next (*) is called on the string, until a valid, non-existant
  #     name is found for each of the segment copies
  #   - (*) = except for +:copy+, where
  #     for the first copy no digit is present, but for the following is,
  #     i.e. the segment names will be +:copy+, +:copy2+, +:copy3+, etc.
  # - Can be overridden, by providing an array of copy names.
  #
  # @!macro [new] ldp_text
  #
  #   <b>Links distribution policy</b>
  #
  #   Depending on the value of the option +distribute+, an end
  #   is eventually selected for distribution of the links.
  #
  #   - +:off+: no distribution performed
  #   - +:E+: links of the E end are distributed
  #   - +:B+: links of the B end are distributed
  #   - +:equal+: select an end for which the number of links is equal to
  #     +factor+, if any; if both, then the E end is selected
  #   - +:auto+: automatically select E or B, trying to maximize the number of
  #     links which can be deleted
  #
  # @param [Integer] factor multiplication factor; if 0, delete the segment;
  #   if 1; do nothing; if > 1; number of copies to create
  # @!macro [new] segment_param
  #   @param segment [String, RGFA::Line::Segment] segment name or instance
  # @param [:lowcase, :upcase, :number, :copy, Array<String>] copy_names
  #   <i>(Defaults to: +:lowcase+)</i>
  #   Array of names for the copies of the segment,
  #   or a symbol, which defines a system to compute the names from the name of
  #   the original segment. See "Automatic computation of the copy names".
  # @!macro [new] conserve_components
  #   @param [Boolean] conserve_components <i>(Defaults to: +true+)</i>
  #     If factor == 0 (i.e. deletion), delete segment only if
  #     #cut_segment?(segment) is +false+ (see RGFA API).
  # @!macro [new] ldp_param
  #   @param distribute
  #     [RGFATools::Multiplication::LINKS_DISTRIBUTION_POLICY]
  #     <i>(Defaults to: +:auto+)</i>
  #     Determines if and for which end of the segment, links are distributed
  #     among the copies. See "Links distribution policy".
  # @!macro [new] origin_tag
  #   @param origin_tag [Symbol] <i>(Defaults to: +:or+)</i>
  #     Name of the custom tag to use for storing origin information.
  #
  # @return [RGFA] self
  def multiply_extended(segment, factor,
                       copy_names: :lowcase,
                       distribute: :auto,
                       conserve_components: true,
                       origin_tag: :or)
    s, sn = segment_and_segment_name(segment)
    s.set(origin_tag, sn) if !s.get(origin_tag)
    copy_names = compute_copy_names(copy_names, sn, factor)
    multiply_without_rgfatools(sn, factor,
                               copy_names: copy_names,
                               conserve_components: conserve_components)
    distribute_links(distribute, sn, copy_names, factor)
    return self
  end

  private

  Redefined = [:multiply]

  def select_distribute_end(links_distribution_policy, segment_name, factor)
    accepted = RGFATools::Multiplication::LINKS_DISTRIBUTION_POLICY
    if !accepted.include?(links_distribution_policy)
      raise "Unknown links distribution policy #{links_distribution_policy}, "+
        "accepted values are: "+
        accepted.inspect
    end
    return nil if links_distribution_policy == :off
    if [:B, :E].include?(links_distribution_policy)
      return links_distribution_policy
    end
    s = segment(segment_name)
    esize = s.dovetails(:R).size
    bsize = s.dovetails(:L).size
    auto_select_distribute_end(factor, bsize, esize,
                               links_distribution_policy == :equal)
  end

  # (keep separate for testing)
  def auto_select_distribute_end(factor, bsize, esize, equal_only)
    if esize == factor
      return :E
    elsif bsize == factor
      return :B
    elsif equal_only
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
    return if factor < 2
    end_type = select_distribute_end(links_distribution_policy,
                                     segment_name, factor)
    return nil if end_type.nil?
    et_links = segment(segment_name).dovetails(end_type == :B ? :L : :R)
    diff = [et_links.size - factor, 0].max
    links_signatures = et_links.map do |l|
      l.other_end([segment_name, end_type]).join
    end
    ([segment_name]+copy_names).each_with_index do |sn, i|
      segment(sn).dovetails(end_type == :B ? :L : :R).each do |l|
        l_sig = l.other_end([sn, end_type]).join
        to_save = links_signatures[i..i+diff].to_a
        l.disconnect! unless to_save.include?(l_sig)
      end
    end
  end

  def segment_and_segment_name(segment_or_segment_name)
    if segment_or_segment_name.kind_of?(RGFA::Line)
      s = segment_or_segment_name
      sn = segment_or_segment_name.name
    else
      sn = segment_or_segment_name.to_sym
      s = segment(sn)
    end
    return s, sn
  end

end
