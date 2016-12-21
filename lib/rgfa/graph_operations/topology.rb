#
# Methods which analyse the topology of the graph.
#
# @tested_in XXX
#
module RGFA::GraphOperations::Topology

  require "set"

  # Does the removal of the link alone divide a component
  # of the graph into two?
  # @return [Boolean]
  # @param link [RGFA::Line::Edge::Link] a link
  def cut_link?(link)
    return false if link.circular?
    return true if link.from.dovetails(link.from_end.end_type.invert).size == 0
    return true if link.to.dovetails(link.to_end.end_type.invert).size == 0
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
        l.other_end([segment_name, et]).invert
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

  # Counts the dead ends.
  #
  # Dead ends are here defined as segment ends without dovetail edges.
  #
  # @return [Integer] number of dead ends in the graph
  def n_dead_ends
    segments.inject(0) do |n,s|
      [:L, :R].each {|e| n+= 1 if s.dovetails(e).empty?}
      n
    end
  end

  # Number of dovetail edges in the graph
  #
  # @return [Integer] number of links (GFA1) or E-lines representing a
  #   dovetail alignment (GFA2)
  def n_dovetails
    segments.inject(0) do |n,s|
      [:L, :R].each {|e| n += s.dovetails(e).size}
      n
    end
    return n / 2
  end

  # Number of internal edges in the graph
  #
  # @return [Integer] number of edges representing non-dovetail/non-containment
  #   alignments
  def n_internals
    segments.inject(0) do |n,s|
      n += s.internals.size
      n
    end
    return n / 2
  end

  # Number of containments in the graph
  #
  # @return [Integer] number of containments (GFA1) or E-lines
  #   representing containments (GFA2)
  def n_containments
    segments.inject(0) do |n,s|
      n += s.edges_to_contained.size
      n += s.edges_to_containers.size
      n
    end
    return n / 2
  end

  # Output basic statistics about the graph's sequence and topology
  # information.
  #
  # @param [boolean] short compact output as a single text line
  #
  # Compact output has the following keys:
  # - +ns+: number of segments
  # - +nd+: number of dovetail overlaps
  # - +cc+: number of connected components
  # - +de+: number of dead ends
  # - +tl+: total length of segment sequences
  # - +50+: N50 segment sequence length
  #
  # Normal output outputs a table with the same information, plus some
  # additional one: the length of the largest component, as well as the shortest
  # and largest and 1st/2nd/3rd quartiles of segment sequence length.
  #
  # @return [String] sequence and topology information collected from the graph.
  #
  def info(short = false)
    q, n50, tlen = lenstats
    nde = n_dead_ends()
    ndv = n_dovetails()
    cc = connected_components()
    retval = []
    if short
      retval << "ns=#{segments.size}"
      retval << "nd=#{ndv}"
      retval << "cc=#{cc.size}"
      retval << "de=#{nde}"
      retval << "tl=#{tlen}"
      retval << "50=#{n50}"
      spacer = "\t"
    else
      nin = n_internals()
      ncn = n_containments()
      pde = "%.2f%%" % ((nde.to_f*100) / (segments.size*2))
      ndv_s = "%.2f%%" % ((ndv.to_f) / (segments.size))
      nin_s = "%.2f%%" % ((nin.to_f) / (segments.size))
      ncn_s = "%.2f%%" % ((ncn.to_f) / (segments.size))
      gap_s = "%.2f%%" % ((gaps.size.to_f) / (segments.size))
      frg_s = "%.2f%%" % ((fragments.size.to_f) / (segments.size))
      retval << "== Specification version"
      retval << "GFA version:                 #{version}"
      retval << ""
      retval << "== Header"
      retval << "Version tag in header:       #{header.VN ? header.VN : 'n.a.'}"
      retval << "TS tag in header:            #{header.TS ? header.TS : 'n.a.'}"
      retval << "Number of tags in header:    #{headers.size}"
      retval << "Duplicated tags in header:   #{header.n_duptags}"
      retval << ""
      retval << "== Graph elements"
      retval << "Segment count:               #{segments.size}"
      retval << "Edges count:                 #{ndv + nin + ncn}"
      retval << "- dovetails:                 #{ndv}"
      retval << "- containments:              #{ncn}"
      retval << "- other (internal):          #{nin}"
      retval << "Gaps count:                  #{gaps.size}"
      retval << "Fragments count:             #{fragments.size}"
      retval << ""
      retval << "== Groups"
      retval << "Paths count:                 #{paths.size}"
      retval << "Sets count:                  #{sets.size}"
      retval << ""
      retval << "== Other GFA lines"
      retval << "Comment lines:               #{comments.size}"
      retval << "Custom-type records:         #{custom_records.size}"
      retval << ""
      retval << "== Segments connectivity"
      retval << "Dovetails/segment:           #{ndv_s}"
      retval << "Segment dead ends (no dov.): #{nde}"
      retval << "Segment ends, % dead:        #{pde}"
      retval << "Internal edges/segment:      #{nin_s}"
      retval << "Containments/segment:        #{ncn_s}"
      retval << "Gaps/segment:                #{gap_s}"
      retval << "Fragments/segment:           #{frg_s}"
      retval << ""
      retval << "== Graph components (dovetails connections)"
      retval << "Connected components:        #{cc.size}"
      cc.map!{|c|c.map{|sn|segment!(sn).length!}.inject(:+)}
      retval << "Largest component (bp):      #{cc.last}"
      retval << ""
      retval << "== Segments sequence statistics"
      retval << "Total segments length (bp):  #{tlen}"
      retval << "N50 (bp):                    #{n50}"
      retval << "Shortest segment (bp):       #{q[0]}"
      retval << "Lower quartile segment (bp): #{q[1]}"
      retval << "Median segment (bp):         #{q[2]}"
      retval << "Upper quartile segment (bp): #{q[3]}"
      retval << "Longest segment (bp):        #{q[4]}"
      spacer = "\n"
    end
    return retval.join(spacer)
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
