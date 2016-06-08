#
# Extensions of the String class to handle CIGAR strings
#
module GFA::CIGAR

  def cigar_operations
    return "*" if self == "*"
    raise TypeError if self !~ /^([0-9]+[MIDNSHPX=])+$/
    scan(/[0-9]+[MIDNSHPX=]/).map do |op|
      oplen = op[0..-2].to_i
      opcode = op[-1..-1]
      [oplen, opcode]
    end
  end

  def reverse_cigar_operations
    return "*" if self == "*"
    self.cigar_operations.reverse.map do |oplen, opcode|
      if opcode == "I"
        opcode = "D"
      elsif opcode == "D"
        opcode = "I"
      end
      [oplen, opcode]
    end
  end

end

class String
  include GFA::CIGAR
end
