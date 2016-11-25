require_relative "error"

module RGFA::SymbolInvert

  def invert
    case self
    when :+ then :-
    when :- then :+
    when :L then :R
    when :R then :L
    when :> then :<
    when :< then :>
    else
      raise RGFA::ValueError,
        "The symbol #{self.inspect} has no inverse."
    end
  end

end

class Symbol
  include RGFA::SymbolInvert
end
