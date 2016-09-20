#
# Methods which edit the graph components without traversal
#
module RGFATools::SuperfluousLinks

  # Remove superfluous links in the presence of mandatory links
  # for a single segment
  # @return [RGFA] self
  # @!macro segment_param
  # @!macro [new] conserve_components_links
  #   @param [Boolean] conserve_components <i>(Defaults to: +true+)</i>
  #     delete links only if #cut_link?(link) is +false+ (see RGFA API).
  def enforce_segment_mandatory_links(segment, conserve_components: true)
    sn = segment_and_segment_name(segment)[1]
    se = {}
    l = {}
    [:B, :E].each do |et|
      se[et] = [sn, et]
      l[et] = links_of(se[et])
    end
    cs = connectivity_symbols(l[:B].size, l[:E].size)
    if cs == [1, 1]
      oe = {}
      [:B, :E].each {|et| oe[et] = l[et][0].other_end(se[et])}
      return if oe[:B] == oe[:E]
      [:B, :E].each {|et| delete_other_links(oe[et], se[et],
                                    conserve_components: conserve_components)}
    else
      i = cs.index(1)
      return if i.nil?
      et = [:B, :E][i]
      oe = l[et][0].other_end(se[et])
      delete_other_links(oe, se[et], conserve_components: conserve_components)
    end
    self
  end

  # Remove superfluous links in the presence of mandatory links
  # in the entire graph
  # @!macro conserve_components_links
  # @return [RGFA] self
  def enforce_all_mandatory_links(conserve_components: true)
    segment_names.each {|sn| enforce_segment_mandatory_links(sn,
                               conserve_components: conserve_components)}
    self
  end

  # Remove links of segment to itself
  # @!macro segment_param
  # @return [RGFA] self
  def remove_self_link(segment)
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment
    unconnect_segments(segment_name, segment_name)
    self
  end

  # Remove all links of segments to themselves
  # @return [RGFA] self
  def remove_self_links
    segment_names.each {|sn| remove_self_link(sn)}
    self
  end

end
