#
# Methods which analyse the connectivity of the graph.
#
module RGFA::GraphOperations::Connectivity

  require "set"

  # Does the removal of the link alone divide a component
  # of the graph into two?
  # @return [Boolean]
  # @param link [RGFA::Line::Edge::Link] a link
  def cut_link?(link)
    return false if link.circular?
    return true if link.from.dovetails(link.from_end.end_type_inverted).size == 0
    return true if link.to.dovetails(link.to_end.end_type_inverted).size == 0
    c = {}
    [:from, :to].each do |et|
      c[et] = Set.new
      visited = Set.new
      segend = link.send(:"#{et}_end")
      visited << segend.name
      visited << link.other_end(segend).name
      traverse_component(segend, c[et], visited)
    end
    return c[:from] != c[:to]
  end

  # Does the removal of the segment and its links divide a
  # component of the graph into two?
  # @param segment
  #   [Symbol, String, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #   a segment name or instance
  # @return [Boolean]
  def cut_segment?(segment)
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment
    segment = segment!(segment)
    return false if [[0,0],[0,1],[1,0]].include?(segment.connectivity)
    start_points = []
    [:L, :R].each do |et|
      start_points += segment.dovetails(et).map do |l|
        l.other_end([segment_name, et]).invert_end_type
      end
    end
    cc = []
    start_points.uniq.each do |start_point|
      cc << Set.new
      visited = Set.new
      visited << segment_name
      traverse_component(start_point, cc.last, visited)
    end
    return cc.any?{|c|c != cc[0]}
  end

  # Find the connected component of the graph in which a segment is included
  # @return [Array<String>]
  #   array of segment names
  # @param segment
  #   [Symbol, String, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #   a segment name or instance
  # @param visited [Set<String>] a set of segments to ignore during graph
  #   traversal; all segments in the found component will be added to it
  def segment_connected_component(segment, visited = Set.new)
    sn = segment.kind_of?(RGFA::Line) ? segment.name : segment
    visited << sn
    c = [sn]
    [:L, :R].each {|e| traverse_component([sn, e], c, visited)}
    return c
  end

  # Find the connected components of the graph
  # @return [Array<Array<String>>]
  #   array of components, each an array of segment names
  def connected_components
    components = []
    visited = Set.new
    segment_names.each do |sn|
      next if visited.include?(sn)
      components << segment_connected_component(sn, visited)
    end
    return components
  end

  # Split connected components of the graph into single-component RGFAs
  # @return [Array<RGFA>]
  def split_connected_components
    retval = []
    ccs = connected_components
    ccs.each do |cc|
      gfa2 = self.clone
      gfa2.rm(gfa2.segment_names - cc)
      retval << gfa2
    end
    return retval
  end

  private

  def traverse_component(segment_end, c, visited)
    segment_end = segment_end.to_segment_end
    s = segment(segment_end.segment)
    s.dovetails(segment_end.end_type).each do |l|
      oe = l.other_end(segment_end)
      sn = oe.name
      next if visited.include?(sn)
      visited << sn
      c << sn
      [:L, :R].each {|e| traverse_component([sn, e], c, visited)}
    end
  end

end
