import gfapy

class MultiplicationExtended:

  '''Allowed values for the links_distribution_policy option'''
  LINKS_DISTRIBUTION_POLICY = ["off", "auto", "equal", "L", "R"]

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
  #   - +:L/:R+: links of the specified end are distributed
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

  def _select_distribute_end(self, links_distribution_policy,
                             segment_name, factor):
    if links_distribution_policy not in self.LINKS_DISTRIBUTION_POLICY:
      raise gfa.ArgumentError("Unknown links distribution policy {}\n".format(links_distribution_policy)+
        "accepted values are: {}".format(", ".join(self.LINKS_DISTRIBUTION_POLICY)))
    if links_distribution_policy == "off":
      return None
    if links_distribution_policy in ["L", "R"]:
      return links_distribution_policy
    else:
      s = self.segment(segment_name)
      esize = len(s.dovetails_of_end("R"))
      bsize = len(s.dovetails_of_end("L"))
      return self._auto_select_distribute_end(factor, bsize, esize,
                                       links_distribution_policy == "equal")

  # (keep separate for testing)
  # @tested_in unit_multiplication
  @staticmethod
  def _auto_select_distribute_end(factor, bsize, esize, equal_only):
    if esize == factor:
      return "R"
    elif bsize == factor:
      return "L"
    elif equal_only:
      return None
    elif esize < 2:
      if bsize < 2:
        return None
      else:
        return "L"
    elif bsize < 2:
      return "R"
    elif esize < factor:
      if bsize <= esize:
        return "R"
      elif bsize < factor:
        return "L"
      else:
        return "R"
    elif bsize < factor:
      return "L"
    elif bsize <= esize:
      return "L"
    else:
      return "R"

  def _distribute_links(self, links_distribution_policy, segment_name,
                        copy_names, factor):
    if factor < 2:
      return
    end_type = self._select_distribute_end(links_distribution_policy,
                                           segment_name, factor)
    if end_type is None:
      return
    et_links = self.segment(segment_name).dovetails_of_end(end_type)
    diff = max([len(et_links)-factor, 0])
    links_signatures = list([repr(l.other_end(gfapy.SegmentEnd(segment_name, \
                          end_type))) for l in et_links])
    for i, sn in enumerate([segment_name]+copy_names):
      to_keep = links_signatures[i:i+diff+1]
      links = self.segment(sn).dovetails_of_end(end_type).copy()
      for l in links:
        l_sig = repr(l.other_end(gfapy.SegmentEnd(sn, end_type)))
        if l_sig not in to_keep:
          l.disconnect()

  def _segment_and_segment_name(self, segment_or_segment_name):
    if isinstance(segment_or_segment_name, gfapy.Line):
      s = segment_or_segment_name
      sn = segment_or_segment_name.name
    else:
      s = self.segment(segment_or_segment_name)
      sn = segment_or_segment_name
    return s, sn
