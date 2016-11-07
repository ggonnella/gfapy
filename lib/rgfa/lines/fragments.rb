#
# Methods for the RGFA class, which allow to handle fragment lines.
#
module RGFA::Lines::Fragments

  # All fragment lines of the graph
  # @return [Array<RGFA::Line::Fragment>]
  def fragments
    @records[:F]
  end

end
