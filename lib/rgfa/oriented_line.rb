require_relative "error"

# A line or line identifier plus an orientation.
#
class RGFA::OrientedLine

  def initialize(line, orient)
    @line = line
    @orient = orient
    @editable = true
  end

  def line
    @line
  end

  def orient
    @orient
  end

  def line=(line)
    if @editable
      @line = line
    else
      raise "RGFA::OrientedLine instance cannot be edited (#{self})"
    end
  end

  def orient=(orient)
    if @editable
      @orient = orient
    else
      raise "RGFA::OrientedLine instance cannot be edited (#{self})"
    end
  end

  # @return [Symbol] the line name
  def name
    @line.to_sym
  end

  def validate
    validate_line
    validate_orient
    return nil
  end

  # @return [RGFA::OrientedLine] same line, inverted orientation
  def invert
    RGFA::OrientedLine.new(@line, @orient.invert)
  end

  # @return [String] line name and orientation
  def to_s
    "#{name}#{orient}"
  end

  # Compare the segment names and orientations of two instances
  #
  # @param [RGFA::OrientedLine,Array] other the other instance
  # @return [Boolean]
  def ==(other)
    case other
    when RGFA::OrientedLine
    when Array
      other = other.to_oriented_line
    when String, Symbol
      other = other.to_s.to_oriented_line
    else
      false
    end
    (self.name == other.name) and
      (self.orient == other.orient)
  end

  # @api private
  def block
    @editable = false
  end

  # @api private
  def unblock
    @editable = true
  end

  def to_oriented_line
    self
  end

  private

  def validate_orient
    if ![:+,:-].include(@orient)
      raise RGFA::ValueError,
        "Invalid orientation (#{@orient})"
    end
  end

  def validate_line
    case @line
    when RGFA::Line
      string = @line.name
    when Symbol, String
      string = @line
    else
      raise RGFA::TypeError,
        "Invalid class (#{@line.class}) for line reference (#{@line})"
    end
    if string !~ /^[!-~]+$/
      raise RGFA::FormatError,
      "#{string.inspect} is not a valid GFA2 identifier\n"+
      "(it contains spaces or non-printable characters)"
    end
  end

end

class String
  def to_oriented_line
    RGFA::OrientedLine.new(self[0..-2].to_sym, self[-1].to_sym)
  end
end

class Array
  def to_oriented_line
    RGFA::OrientedLine.new(self[0].to_sym, self[1].to_sym)
  end
end

module OL
  def [](line,orient)
    RGFA::OrientedLine.new(line,orient)
  end
  module_function :[]
end
Kernel.extend(OL)
