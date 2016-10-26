class RGFA::Position

  def initialize(value, last)
    @value = value
    @last = last
  end

  attr_accessor :value, :last

  def validate!
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
    if string.last == "$"
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

end

class String

  def to_position
    return RGFA::Position.from_string(self)
  end

end
