#
# Methods for the RGFA class, which involve a traversal of the graph following
# links
#
module RGFATools::PBubbles

  require "set"

  # Removes all p-bubbles in the graph
  # @return [RGFA] self
  def remove_p_bubbles
    visited = Set.new
    segment_names.each do |sn|
      next if visited.include?(sn)
      if connectivity(sn) == [1,1]
        s1 = neighbours([sn, :B])[0]
        s2 = neighbours([sn, :E])[0]
        n1 = neighbours(s1).sort
        n2 = neighbours(s2).sort
        n1.each {|se| visited << se[0].name}
        if n1 == n2.map{|se| se.invert_end_type}
          remove_proven_p_bubble(s1, s2, n1)
        end
      end
    end
    return self
  end

  # Removes a p-bubble between segment_end1 and segment_end2
  # @param [RGFA::SegmentEnd] segment_end1 a segment end
  # @param [RGFA::SegmentEnd] segment_end2 another segment end
  # @!macro [new] count_tag
  #   @param count_tag [Symbol] <i>(defaults to: +:RC+ or the value set by
  #     {#set_default_count_tag})</i> the count tag to use for coverage
  #     computation
  # @!macro [new] unit_length
  #   @param unit_length [Integer] <i>(defaults to: 1 or the value set by
  #     {#set_count_unit_length})</i> the unit length to use for coverage
  #     computation
  # @return [RGFA] self
  #
  def remove_p_bubble(segment_end1, segment_end2,
                      count_tag: @default[:count_tag],
                      unit_length: @default[:unit_length])
    n1 = neighbours(segment_end1).sort
    n2 = neighbours(segment_end2).sort
    raise if n1 != n2.map{|se| se.invert_end_type}
    raise if n1.any? {|se| connectivity(se[0]) != [1,1]}
    remove_proven_p_bubble(segment_end1, segment_end2, n1,
                           count_tag: count_tag,
                           unit_length: unit_length)
    return self
  end

  private

  def remove_proven_p_bubble(segment_end1, segment_end2, alternatives,
                             count_tag: @default[:count_tag],
                             unit_length: @default[:unit_length])
    coverages = alternatives.map{|s|segment!(s[0]).coverage(
      count_tag: count_tag, unit_length: unit_length)}
    alternatives.delete_at(coverages.index(coverages.max))
    alternatives.each {|s| delete_segment(s[0])}
  end

end
