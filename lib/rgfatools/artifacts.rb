#
# Methods which edit the graph components without traversal
#
module RGFATools::Artifacts

  # Remove connected components whose sum of lengths of the segments
  # is under a specified value.
  # @param minlen [Integer] the minimum length
  # @return [RGFA] self
  def remove_small_components(minlen)
    rm(connected_components.select {|cc|
      cc.map{|sn|segment(sn).length}.reduce(:+) < minlen })
    self
  end

  # Remove end segments, whose sequence length is under a specified value.
  # @param minlen [Integer] the minimum length
  # @return [RGFA] self
  def remove_dead_ends(minlen)
    segments.each do |s|
      c = connectivity(s)
      rm(s) if s.length < minlen and
        (c[0] == 0 or c[1] == 0) and
          !cut_segment?(s)
    end
    self
  end

end
