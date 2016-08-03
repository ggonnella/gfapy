begin
  require "rgl/adjacency"
  require "rgl/implicit"
  require_relative "error"

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
          s = segment(oriented_segment.segment)
          o = oriented_segment.orient
          s.links[:from][o].each do |l|
            os = [segment(l.to), l.to_orient].to_oriented_segment
            block.call(os)
          end
          o = oriented_segment.invert_orient
          s.links[:to][o].each do |l|
            os = [segment(l.from), l.from_orient].to_oriented_segment
            block.call(os.invert_orient)
          end
        end
        g.directed = true
      end
    end

    # Creates an RGL graph, assuming that all links orientations
    # are "+".
    #
    # @raise [RGFA::RGL::ValueError] if the graph contains any link where
    #   from_orient or to_orient is :-
    # @return [RGL::ImplicitGraph] an rgl implicit directed graph;
    #   where vertices are RGFA::Segment objects
    def to_rgl_unoriented
      RGL::ImplicitGraph.new do |g|
        g.vertex_iterator {|block| self.each_segment {|s| block.call(s)}}
        g.adjacent_iterator do |s, bl|
          s = segment(s)
          s.links[:from][:+].each do |l|
            if l.to_orient == :-
              raise RGFA::RGL::ValueError,
                "Graph contains links with segments in reverse orientations"
            end
            bl.call(segment(l.to))
          end
          if s.links[:from][:-].size > 0
            raise RGFA::RGL::ValueError,
              "Graph contains links with segments in reverse orientations"
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
      #   @raise [RGFA::RGL::InvalidFormatError] if the graph cannot be
      #     converted
      #
      #   @return [RGFA] a new RGFA instance
      def from_rgl(g)
        gfa = RGFA.new
        if not (g.respond_to?(:each_vertex) and
                g.respond_to?(:each_edge))
          raise RGFA::RGL::InvalidFormatError,
            "#{g} is not a valid RGL graph"
        end
        if not g.directed?
          raise RGFA::RGL::InvalidFormatError,
            "#{g} is not a directed graph"
        end
        g.each_vertex {|v| add_segment_if_new(gfa, v)}
        g.each_edge do |s, t|
          gfa << RGFA::Line::Link.new(segment_name_and_orient(s) +
                                      segment_name_and_orient(t) +
                                      ["*"])
        end
        gfa
      end

      private

      def add_segment_if_new(gfa, v)
        # RGFA::OrientedSegment or GFA::GraphVertex
        v = v.segment if v.respond_to?(:segment)
        if v.kind_of?(Symbol)
          # segment name as symbol
          return if gfa.segment_names.include?(v)
          v = RGFA::Line::Segment.new([v.to_s, "*"])
        elsif v.kind_of?(String)
          a = v.split("\t")
          if a[0] == "S"
            # string representation of segment
            return if gfa.segment_names.include?(a[1].to_sym)
            v = RGFA::Line::Segment.new(a[1..-1])
          else
            # segment name as string
            return if gfa.segment_names.include?(v.to_sym)
            v = RGFA::Line::Segment.new([v, "*"])
          end
        end
        return if gfa.segment_names.include?(v.name)
        gfa << v
      end

      def segment_name_and_orient(s)
        # default orientation
        o = s.respond_to?(:orient) ? s.orient.to_s : "+"
        # RGFA::Line::Segment (also embedded in RGFA::OrientedSegment)
        if s.respond_to?(:name)
          s = s.name.to_s
        elsif s.respond_to?(:segment)
          # GFA::GraphVertex
          s = s.segment.to_s
        elsif s.respond_to?(:split)
          a = s.split("\t")
          s = a[1] if a[0] == "S"
        else
          s = s.to_s
        end
        return s, o
      end

    end

  end

  module RGL::Graph

    # @!macro from_rgl
    def to_rgfa
      RGFA.from_rgl(self)
    end

  end

  # Exception raised if conversion is impossible due to unexpected values
  class RGFA::RGL::ValueError < RGFA::Error; end

  # Exception raised if conversion is impossible due to general format problems
  class RGFA::RGL::InvalidFormatError < RGFA::Error; end

rescue LoadError

  module RGFA::RGL
  end

end
