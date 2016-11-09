#
# Methods which analyse the connectivity of the graph.
#
module RGFA::GraphOperations::Connectivity

  require "set"

  # Computes the connectivity of a segment from its number of links.
  #
  # @param segment
  #   [String, Symbol, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #   segment name or instance
  #
  # @return [Array<conn_symbol,conn_symbol>]
  #  conn. symbols respectively of the :B and :E ends of +segment+.
  #
  # <b>Connectivity symbol:</b> (+conn_symbol+)
  # - Let _n_ be the number of links to an end (+:B+ or +:E+) of a segment.
  #   Then the connectivity symbol is +:M+ if <i>n > 1</i>, otherwise _n_.
  #
  def connectivity(segment)
    connectivity_symbols(links_of([segment, :B]).size,
                         links_of([segment, :E]).size)
  end

  # Does the removal of the link alone divide a component
  # of the graph into two?
  # @return [Boolean]
  # @param link [RGFA::Line::Edge::Link] a link
  def cut_link?(link)
    return false if link.circular?
    return true if links_of(link.from_end.invert_end_type).size == 0
    return true if links_of(link.to_end.invert_end_type).size == 0
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
    cn = connectivity(segment_name)
    return false if [[0,0],[0,1],[1,0]].include?(cn)
    start_points = []
    [:B, :E].each do |et|
      start_points += links_of([segment_name, et]).map do |l|
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
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment
    visited << segment_name
    c = [segment_name]
    traverse_component([segment_name, :B], c, visited)
    traverse_component([segment_name, :E], c, visited)
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
    links_of(segment_end).each do |l|
      oe = l.other_end(segment_end)
      sn = oe.name
      next if visited.include?(sn)
      visited << sn
      c << sn
      traverse_component([sn, :B], c, visited)
      traverse_component([sn, :E], c, visited)
    end
  end

  def connectivity_symbols(n,m)
    [connectivity_symbol(n), connectivity_symbol(m)]
  end

  def connectivity_symbol(n)
    n > 1 ? :M : n
  end

end
