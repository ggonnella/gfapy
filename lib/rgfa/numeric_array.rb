#
# A numeric array representable using the data type B of the GFA specification
#
class RGFA::NumericArray < Array

  # Subtypes for signed integers, from the smallest to the largest
  SIGNEDINT_SUBTYPE = %W[c s i]

  # Subtypes for unsigned integers, from the smallest to the largest
  UNSIGNED_INT_SUBTYPE = SIGNEDINT_SUBTYPE.map{|st|st.upcase}

  # Subtypes for integers
  INT_SUBTYPE = UNSIGNED_INT_SUBTYPE + SIGNEDINT_SUBTYPE

  # Subtypes for floats
  FLOAT_SUBTYPE = ["f"]

  # Subtypes
  SUBTYPE = INT_SUBTYPE + FLOAT_SUBTYPE

  # Number of bits of unsigned integer subtypes
  SUBTYPE_BITS = {"c" => 8, "s" => 16, "i" => 32}

  # Range for integer subtypes
  SUBTYPE_RANGE = Hash[
      INT_SUBTYPE.map do |subtype|
        [
         subtype,
         if subtype == subtype.upcase
           0..((2**SUBTYPE_BITS[subtype.downcase])-1)
         else
           (-(2**(SUBTYPE_BITS[subtype]-1)))..((2**(SUBTYPE_BITS[subtype]-1))-1)
         end
        ]
      end
    ]

  # Validate the numeric array
  #
  # @raise RGFA::NumericArray::ValueError if the array is not valid
  def validate!
    compute_subtype
  end

  # Computes the subtype of the array from its content.
  #
  # If all elements are float, then the computed subtype is "f".
  # If all elements are integer, the smallest possible numeric subtype
  # is computed; thereby,
  # if all elements are non-negative, an unsigned subtype is selected,
  # otherwise a signed subtype.
  # In all other cases an exception is raised.
  #
  # @raise RGFA::NumericArray::ValueError if the array is not a valid numeric
  #   array
  # @return [RGFA::NumericArray::SUBTYPE]
  def compute_subtype
    if all? {|f|f.kind_of?(Float)}
      subtype = "f"
    else
      e_max = nil
      e_min = nil
      each do |e|
        if !e.kind_of?(Integer)
          raise RGFA::NumericArray::ValueError,
            "NumericArray does not contain homogenous numeric values\n"+
            "Content: #{inspect}"
        end
        e_max = e if e_max.nil? or e > e_max
        e_min = e if e_min.nil? or e < e_min
      end
      if e_min < 0
        subtype = nil
        SIGNED_INT_SUBTYPE.each do |st|
          range = RGFA::NumericArray::SUBTYPE_RANGE[st]
          if range.include?(e_min) and range.include?(e_max)
            subtype = st
            break
          end
        end
      else
        UNSIGNED_INT_SUBTYPE.each do |st|
          range = RGFA::NumericArray::SUBTYPE_RANGE[st]
          if e_max < range.max
            subtype = st
            break
          end
        end
      end
      if subtype.nil?
        raise RGFA::NumericArray::ValueError,
          "NumericArray: values are outside of all integer subtype ranges\n"+
          "Content: #{inspect}"
      end
    end
    subtype
  end

  # Return self
  # @param validate [Boolean] <i>(default: +false+)</i>
  #   if +true+, validate the range of the numeric values, according
  #   to the array subtype
  # @raise [RGFA::NumericArray::ValueError] if validate is set and
  #   any value is not compatible with the subtype
  # @return [RGFA::NumericArray]
  def to_numeric_array(validate: false)
    validate! if validate
    self
  end

  # GFA datatype B representation of the numeric array
  # @raise [RGFA::NumericArray::ValueError] if the array
  #   if not a valid numeric array
  # @return [String]
  def to_s
    subtype = compute_subtype
    "#{subtype},#{join(",")}"
  end

end

# Exception raised if a value in a numeric array is not compatible
# with the selected subtype
class RGFA::NumericArray::ValueError < RangeError; end

# Exception raised if an invalid subtype code is found
class RGFA::NumericArray::TypeError < ArgumentError; end

#
# Method to create a numeric array from an array
#
class Array
  # Create a numeric array from an Array instance
  # @param validate [Boolean] <i>(default: +true+)</i>
  #   if +true+, validate the range of the numeric values, according
  #   to the array subtype
  # @raise [RGFA::NumericArray::ValueError] if validate is set and
  #   any value is not compatible with the subtype
  # @return [RGFA::NumericArray] the numeric array
  def to_numeric_array(validate: true)
    na = RGFA::NumericArray.new(self)
    na.validate! if validate
    na
  end
end

#
# Method to create a numeric array from a string
#
class String
  # Create a numeric array from a string
  # @param validate [Boolean] <i>(default: +true+)</i>
  #   if +true+, validate the range of the numeric values, according
  #   to the array subtype
  # @raise [RGFA::NumericArray::ValueError] if validate is set and
  #   any value is not compatible with the subtype
  # @raise [RGFA::NumericArray::TypeError] if the subtype code is invalid
  # @return [RGFA::NumericArray] the numeric array
  def to_numeric_array(validate: true)
    elems = split(",")
    subtype = elems.shift
    integer = (subtype != "f")
    if integer
      range = RGFA::NumericArray::SUBTYPE_RANGE[subtype]
    elsif !RGFA::NumericArray::SUBTYPE.include?(subtype)
      raise RGFA::NumericArray::TypeRror, "Subtype #{subtype} unknown"
    end
    elems.map do |e|
      begin
        if integer
          e = Integer(e)
          if validate and not range.include?(e)
            raise "NumericArray: value is outside of subtype #{subtype} range\n"+
                  "Value: #{e}\n"+
                  "Range: #{range.inspect}\n"+
                  "Content: #{inspect}"
          end
          e
        else
          Float(e)
        end
      rescue => msg
        raise RGFA::NumericArray::ValueError, msg
      end
    end
  end
end
