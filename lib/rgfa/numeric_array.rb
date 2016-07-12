class RGFA::NumericArray < Array

  B_SUBTYPE_BITS = {"c" => 8, "s" => 16, "i" => 32}

  B_SUBTYPE_RANGE = %W[C c S s I i].map do |subtype|
    if subtype == subtype.upcase
      0..((2**B_SUBTYPE_BITS[subtype.downcase])-1)
    else
      (-(2**(B_SUBTYPE_BITS[subtype]-1)))..((2**(B_SUBTYPE_BITS[subtype]-1))-1)
    end
  end

  def to_gfa_datastring(datatype)
    "#{subtype},#{join(",")}"
  end

  def gfa_datatype
    :B
  end

  def subtype(recompute=false)
    if !defined?(@subtype) or recompute
      if all? {|f|f.kind_of?(Float)}
        @subtype = "f"
      elsif all? {|i|i.kind_of?(Integer)}
        @subtype = "i"
      else
        raise TypeError,
          "Array does not contain homogenous numeric values\n"+
          "Content: #{inspect}"
      end
    end
    @subtype
  end

  def subtype=(s)
    @subtype=(s)
  end

  def to_numeric_array
    self
  end
end

class Array
  def to_numeric_array
    RGFA::NumericArray.new(self)
  end
end

class String
  def to_numeric_array(validate: true)
    elems = split(",")
    subtype = elems.shift
    elems.map do |e|
      if subtype == "f"
        Float(f)
      else
        e = Integer(e)
        if validate
          range = RGFA::NumericArray::B_SUBTYPE_RANGE[subtype].include?(e)
          unless range.include?(e)
            raise "B type #{subtype} values "+
              "must be in the range #{range.inspect}"
          end
        end
        e
      end
    end
  end
end
