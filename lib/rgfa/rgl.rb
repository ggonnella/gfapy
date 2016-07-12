begin
  require "rgl/adjacency"
  require "rgl/implicit"

  #
  # Conversion to RGL graphs
  #
  module RGFA::RGL

    # Creates an RGL graph.
    #
    # @param oriented [Boolean] (defaults to: <i>+true+</i>) may the graph
    #   contain links of segments in different orientation?
    # @return [RGL::ImplicitGraph] an rgl implicit directed graph
    def to_rgl(oriented: true)
      if oriented
        to_rgl_oriented
      else
        to_rgl_unoriented
      end
    end

    # Creates an RGL graph, including links orientations.
    #
    # @return [RGL::ImplicitGraph] an rgl implicit directed graph;
    #   where vertices are [RGFA::Segment, orientation] pairs
    #   (instances of the RGFA::OrientedSegment subclass of Array)
    def to_rgl_oriented
      RGL::ImplicitGraph.new do |g|
        g.vertex_iterator do |block|
          self.each_segment do |segment|
            [:+, :-].each do |orient|
              block.call([segment, orient].to_oriented_segment)
            end
          end
        end
        g.adjacent_iterator do |oriented_segment, block|
          @c.lines("L", oriented_segment.name, :from,
              oriented_segment.orient).each do |l|
            os = [segment(l.to), l.to_orient].to_oriented_segment
            block.call(os)
          end
          @c.lines("L", oriented_segment.name, :to,
              RGFA::OrientedSegment.other(oriented_segment.orient)).each do |l|
            os = [segment(l.from), l.from_orient].to_oriented_segment
            block.call(os.other_orient)
          end
        end
        g.directed = true
      end
    end

    # Creates an RGL graph, assuming that all links orientations
    # are "+".
    #
    # @raise [RuntimeError] if the graph contains any link where
    #   from_orient or to_orient is :-
    # @return [RGL::ImplicitGraph] an rgl implicit directed graph;
    #   where vertices are RGFA::Segment objects
    def to_rgl_unoriented
      RGL::ImplicitGraph.new do |g|
        g.vertex_iterator {|block| self.each_segment {|s| block.call(s)}}
        g.adjacent_iterator do |s, bl|
          @c.lines("L", s, :from, :+).each do |l|
            if l.to_orient == :-
              raise "Graph contains links with segments in reverse orientations"
            end
            bl.call(segment(l.to))
          end
          if @c.lines("L", s, :from, :-).size > 0
            raise "Graph contains links with segments in reverse orientations"
          end
        end
        g.directed = true
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # @param g [RGL::ImplicitGraph, RGL::DirectedAdjacencyGraph] an RGL graph.
      #
      # @!macro[new] from_rgl
      #   <b>Accepted vertex formats</b>:
      #
      #   - RGFA::OrientedSegment, or Array which can be converted to it;
      #     where the first element is a <i>segment specifier</i> (see below)
      #   - <i>segment specifier</i> alone: the orientation is assumed to be :+
      #
      #   The <i>segment specifier</i> can be:
      #   - RGFA::Segment instance
      #   - String, segment representation (e.g. "S\tsegment\t*")
      #   - String, valid segment name (e.g. "segment")
      #
      #   @return [RGFA] a new RGFA instance
      def from_rgl(g)
        gfa = RGFA.new
        if not (g.respond_to?(:each_vertex) and
                g.respond_to?(:each_edge))
          raise "#{g} is not a valid RGL graph"
        end
        if not g.directed?
          raise "#{g} is not a directed graph"
        end
        g.each_vertex do |v|
          v = v.to_oriented_segment rescue [v, :+].to_oriented_segment
          v = v.segment.to_rgfa_line rescue ["S",v.segment,"*"].to_rgfa_line
          gfa << v unless gfa.segment_names.include?(v.name)
        end
        g.each_edge do |s, t|
          s = s.to_oriented_segment rescue [s, :+].to_oriented_segment
          s[0] = s[0].to_rgfa_line rescue s[0]
          t = t.to_oriented_segment rescue [t, :+].to_oriented_segment
          t[0] = t[0].to_rgfa_line rescue t[0]
          gfa << ["L", s.name, s.orient, t.name, t.orient, "*"].to_rgfa_line
        end
        gfa
      end

    end

  end

  module RGL::Graph

    # @!macro from_rgl
    def to_rgfa
      RGFA.from_rgl(self)
    end

  end

  # Is it possible to make also a bidirectional rgl graph?

rescue LoadError

  module RGFA::RGL
  end

end
