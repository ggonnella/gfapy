module RGFA::Line::Common::Virtual

  # Is the line virtual?
  #
  # Is this RGFA::Line a virtual line representation
  # (i.e. a placeholder for an expected but not encountered yet line)?
  # @api private
  # @return [Boolean]
  def virtual?
    @virtual
  end

  # Make a virtual line real.
  # @api private
  # This is called when a line which is expected, and for which a virtual
  # line has been created, is finally found. So the line is converted into
  # a real line, by merging in the line information from the found line.
  # @param real_line [RGFA::Line] the real line fou
  def real!(real_line)
    @virtual = false
    real_line.data.each_pair do |k, v|
      @data[k] = v
    end
  end

end
