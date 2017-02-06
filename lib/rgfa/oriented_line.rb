require_relative "error"

# A line or line identifier plus an orientation.
#
# @tested_in unit_oriented_line
class RGFA::OrientedLine

  # Create an OrientedLine instance
  # @param line [Symbol, RGFA::Line] either a line identifier (Symbol)
  #   or a reference to a line (RGFA::Line subclass instance)
  # @param orient [:+,:-] a symbol defining the orientation
  def initialize(line, orient)
    @line = line
    @orient = orient.to_sym
    @editable = true
  end

  # Get the line
  # @return [RGFA::Line, Symbol] the line identifier or reference
  def line
    @line
  end

  # Get the orientation symbol
  # @return [:+,:-] the orientation symbol
  def orient
    @orient
  end

  # Set the line
  # @param line [Symbol, RGFA::Line] set the line instance
  # @raise [RGFA::RuntimeError] if the line instance is not editable
  # @return [Symbol, RGFA::Line] the line
  def line=(line)
    if @editable
      @line = line
    else
      raise RGFA::RuntimeError,
        "RGFA::OrientedLine instance cannot be edited (#{self})"
    end
  end

  # Set the orientation
  # @param orient [:+,:-] set the orientation symbol
  # @raise [RGFA::RuntimeError] if the line instance is not editable
  # @return [:+,:-] the orientation
  def orient=(orient)
    if @editable
      @orient = orient
    else
      raise RGFA::RuntimeError,
        "RGFA::OrientedLine instance cannot be edited (#{self})"
    end
    return @orient
  end

  # @return [Symbol] the line name
  def name
    @line.to_sym
  end

  # Validate the instance
  # @raise [RGFA::ValueError] if the orientation symbol is not +:++ or +:-+
  # @raise [RGFA::TypeError] if the line is not a string, symbol
  #   or reference to a line (RGFA::Line)
  # @raise [RGFA::FormatError] if the line is a string or symbol and
  #   it contains spacing or non-printable characters
  # @return [void]
  def validate
    validate_line
    validate_orient
    return nil
  end

  # Create an oriented line instance, with the inverted orientation
  # @return [RGFA::OrientedLine] same line, inverted orientation
  def invert
    RGFA::OrientedLine.new(@line, @orient.invert)
  end

  # Compute the string representation of the oriented line
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
      return false
    end
    (self.name == other.name) and
      (self.orient == other.orient)
  end

  # Return self (for compatibility with to_oriented_line of other classes)
  # @return [RGFA::OrientedLine] self
  def to_oriented_line
    self
  end

  # @api private
  module API_PRIVATE

    def block
      @editable = false
    end

    def unblock
      @editable = true
    end
  end

  include API_PRIVATE

  private

  # Delegate methods to the line
  def method_missing(meth, *args, &block)
    @line.send meth, *args, &block
  end

  def validate_orient
    if ![:+,:-].include?(@orient)
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
      "#{string.inspect} is not a valid GFA identifier\n"+
      "(it contains spaces or non-printable characters)"
    end
  end

end

class String
  # Create an oriented line instance from a string, which contains
  # a GFA identifier followed by + or -
  # @return [RGFA::OrientedLine]
  # @tested_in unit_oriented_line
  def to_oriented_line
    RGFA::OrientedLine.new(self[0..-2].to_sym, self[-1].to_sym)
  end
end

class Array
  # Create an oriented line instance from an array, which contains
  # a GFA identifier as first element, and a :+ or :- as second
  # @return [RGFA::OrientedLine]
  # @tested_in unit_oriented_line
  def to_oriented_line
    RGFA::OrientedLine.new(self[0], self[1].to_sym)
  end
end

# Shortcut to create new objects
# using a OL[] syntax
module OL
  # Create an oriented line instance
  # (shortcut for RGFA::OrientedLine.new)
  # @param line [RGFA::Line,Symbol] the line
  # @param orient [:+,:-] the orientation symbol
  # @return [RGFA::OrientedLine]
  def [](line,orient)
    RGFA::OrientedLine.new(line,orient)
  end
  module_function :[]
end
Kernel.extend(OL)
