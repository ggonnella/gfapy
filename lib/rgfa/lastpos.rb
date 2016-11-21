class RGFA::LastPos

  # Create a new LastPos.
  # @see Integer#to_lastpos
  # @see String#to_pos
  def initialize(value)
    @value = value
  end

  attr_accessor :value
  alias_method :to_i, :value

  # Validate a LastPos instance
  # @return nil
  def validate
    if !value.kind_of?(Integer)
      raise RGFA::TypeError,
        "LastPos value shall be an integer, #{value.class} found"
    elsif value < 0
      raise RGFA::ValueError,
        "LastPos value shall be >= 0, #{value} found"
    end
  end

  # String representation, value with a dollar suffix
  # @return [String]
  def to_s
    "#@value$"
  end

  # A lastpos is equal to a lastpos or integer with the same value
  # @return [Boolean]
  # @param other [Integer,RGFA::LastPos] the value to compare.
  def ==(other)
    @value == other.value
  end

  # Redefines respond_to? to consider methods delegated to the value.
  def respond_to?(m, include_all=false)
    super || @value.respond_to?(m, include_all)
  end

  # Returns true
  # @return [true]
  def last?
    true
  end

  # Compatibility with Integer#first?
  # @return [false]
  def first?
    false
  end

  # Subtract other from the lastpos
  # @return [Integer,RGFA::LastPos] a lastpos if other is 0, otherwise an
  #   integer
  def -(other)
    other == 0 ? self.clone : self.value - other.to_i
  end

  private

  # Delegate methods to the value
  def method_missing(meth, *args, &block)
    @value.send meth, *args, &block
  end

end

class String

  # Parse the string representation of a GFA2 position field
  # @return [Integer,RGFA::LastPos] if the string ends with a dollar,
  #   then RGFA::LastPos, otherwise an integer.
  # @param valid [Boolean] <i>defaults to: +false+</i> is the string
  #   guaranteed to be a valid position value?
  def to_pos(valid: false)
    if self[-1] == "$"
      last = true
      s = self[0..-2]
    else
      last = false
      s = self
    end
    begin
      value = Integer(s)
    rescue
      raise RGFA::FormatError,
        "Wrong value for position: #{self}"
    end
    if !valid and value < 0
      raise RGFA::ValueError,
        "Negative position value (#{self})"
    end
    return last ? RGFA::LastPos.new(value) : value
  end

end

class Integer

  # Compatibility with RGFA::LastPos#value
  # @return [self]
  def value
    self
  end

  # Compatibility with RGFA::LastPos#value
  # @return [false]
  def last?
    false
  end

  # Return true if zero
  # @return [Boolean]
  def first?
    self == 0
  end

  # Convert to a RGFA::LastPos instance
  # @return [RGFA::LastPos]
  def to_lastpos(valid: false)
    if !valid and self < 0
      raise RGFA::ValueError,
        "Negative position value (#{self})"
    end
    RGFA::LastPos.new(self)
  end

end
