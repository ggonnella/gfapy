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
      RGL::ImplicitGraph.new do |rgl|
        rgl.vertex_iterator do |block|
          self.each_segment do |segment|
            ["+", "-"].each do |orient|
              block.call([segment, orient].to_oriented_segment)
            end
          end
        end
        rgl.adjacent_iterator do |oriented_segment, block|
          @c.lines("L", oriented_segment.name, :from,
              oriented_segment.orient).each do |l|
            block.call([l.to, l.to_orient].to_oriented_segment)
          end
          @c.lines("L", oriented_segment.name, :to,
              GFA::OrientedSegment.other(oriented_segment.orient)).each do |l|
            block.call([l.from, l.from_orient].to_oriented_segment.other_orient)
          end
        end
        rgl.directed = true
      end
    end
  end

rescue LoadError

  module GFA::RGL
  end

end
