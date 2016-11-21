# A placeholder is used in mandatory fields when a value is not specified.
# Its string representation is an asterisk (+*+).
class RGFA::Placeholder
  # @return [String] string representation (+*+)
  def to_s
    "*"
  end

  # A placeholder is always empty
  # return [true]
  def empty?
    true
  end

  # A placeholder is always valid
  # return [void]
  def validate
  end

  # For compatibility with String#rc (RGFA::Sequence module)
  # @return [self]
  def rc
    self
  end

  # Length/size of a placeholder is always 0
  # @return [self]
  def length
    0
  end

  # @return [true]
  def placeholder?
    true
  end

  alias_method :size, :length

  # Any cut of the placeholder returns the placeholder itself
  # @param anything [Object] ignored
  # @return [self]
  def [](*anything)
    self
  end

  # Adding the placeholder to anything returns the placeholder itself
  # @param anything [Object] ignored
  # @return [self]
  def +(*anything)
    self
  end

  def ==(other)
    other.placeholder?
  end

  alias :eql? :==
  alias :=== :==

end

class String
  def placeholder?
    self == "*"
  end
end

class Symbol
  def placeholder?
    self == :"*"
  end
end

class Array
  def placeholder?
    empty?
  end
end

class Numeric
  def placeholder?
    false
  end
end
