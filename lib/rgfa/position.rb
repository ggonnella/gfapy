class RGFA::Position

  def initialize(value, last)
    @value = value
    @last = last
  end

  attr_accessor :value, :last

  def validate
    if !value.kind_of?(Integer)
      raise RGFA::TypeError
    elsif value < 0
      raise RGFA::ValueError
    end
    if ![true, false, nil].include?(last)
      raise RGFA::TypeError
    end
  end

  def self.from_string(string)
    if string[-1] == "$"
      last = true
      string = string[0..-2]
    else
      last = false
    end
    value = Integer(string) rescue RGFA::FormatError
    return RGFA::Position.new(value, last)
  end

  def to_s
    "#@value#{@last ? '$' : ''}"
  end

  def to_i
    self.value
  end

  def first
    value == 0
  end

  def ==(other)
    if other.kind_of?(RGFA::Position)
      super
    elsif other.respond_to?(:to_i)
      return self.value == other.to_i
    else
      raise RGFA::TypeError,
        "Comparison of #{self.inspect} with #{other.inspect} impossible"
    end
  end

  def +(other)
    if other.kind_of?(RGFA::Position)
      if (other.last and self.value > 0) or
         (self.last and other.value > 0)
        raise "Cannot add to last position"
      else
        v = other.value
      end
    elsif other.respond_to?(:to_i)
      v = other.to_i
    else
      raise RGFA::TypeError,
        "Adding #{self.inspect} to #{other.inspect} failed"
    end
    if v == 0
      return self.clone
    else
      return self.value + v
    end
  end

  def -(other)
    if other.kind_of?(RGFA::Position)
      v = other.value
    elsif other.respond_to?(:to_i)
      v = other.to_i
    else
      raise RGFA::TypeError,
        "Adding #{self.inspect} to #{other.inspect} failed"
    end
    if (v > self.value)
      raise "Negative positions are not allowed"
    elsif v > 0
      return RGFA::Position.new(self.value - v, false)
    else
      return self.clone
    end
  end

end

class String

  def to_position
    return RGFA::Position.from_string(self)
  end

end

class Integer

  def value
    self
  end

  def last
    nil
  end

  def first
    self == 0
  end

end
