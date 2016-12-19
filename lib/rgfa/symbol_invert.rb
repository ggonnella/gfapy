require_relative "error"

# Define the inverted symbol for some symbols which represent boolean
# conditions, i.e. orientation symbols (:+/:-) and segment ends (:L,:R)
# @tested_in unit_symbol_invert
module RGFA::SymbolInvert

  # Invert a symbol describing an orientation or a segment end
  # @raise [RGFA::ValueError] if the symbol has no defined inverted symbol
  # @return [Symbol]
  def invert
    case self
    when :+ then :-
    when :- then :+
    when :L then :R
    when :R then :L
    else
      raise RGFA::ValueError,
        "The symbol #{self.inspect} has no inverse."
    end
  end

end

class Symbol
  include RGFA::SymbolInvert
end
