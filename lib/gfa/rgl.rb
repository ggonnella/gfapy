begin
  require "rgl/adjacency"
  require "rgl/implicit"

  #
  # Conversion to RGL graphs
  #
  module GFA::RGL

    # Converts into a RGL graph
    #
    # @return RGL::ImplicitGraph
    def to_rgl
      RGL::ImplicitGraph.new do |g|
        g.vertex_iterator do |block|
          self.each_segment do |segment|
            ["+", "-"].each do |orient|
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
              GFA::OrientedSegment.other(oriented_segment.orient)).each do |l|
            os = [segment(l.from), l.from_orient].to_oriented_segment
            block.call(os.other_orient)
          end
        end
        g.directed = true
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def from_rgl(g)
        gfa = GFA.new
        if not (g.respond_to?(:each_vertex) and
                g.respond_to?(:each_edge))
          raise "#{g} is not a valid RGL graph"
        end
        if not g.directed?
          raise "#{g} is not a directed graph"
        end
        g.each_vertex do |v|
          v = v.to_oriented_segment rescue [v, "+"].to_oriented_segment
          v = v.segment.to_gfa_line rescue ["S",v.segment,"*"].to_gfa_line
          gfa << v unless gfa.segment_names.include?(v.name)
        end
        g.each_edge do |s, t|
          s = s.to_oriented_segment rescue [s, "+"].to_oriented_segment
          s[0] = s[0].to_gfa_line rescue s[0]
          t = t.to_oriented_segment rescue [t, "+"].to_oriented_segment
          t[0] = t[0].to_gfa_line rescue t[0]
          gfa << ["L", s.name, s.orient, t.name, t.orient, "*"].to_gfa_line
        end
        gfa
      end

    end

  end

  module RGL::Graph

    def to_gfa
      GFA.from_rgl(self)
    end

  end

  # Is it possible to make also a bidirectional rgl graph?

rescue LoadError

  module GFA::RGL
  end

end
