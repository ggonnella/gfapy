#
# Extensions of the String class to handle nucleotidic sequences
#
module RGFA::Sequence

  # Computes the reverse complement of a nucleotidic sequence
  #
  # @return [String] reverse complement, without newlines and spaces
  # @return [String] "*" if string is "*"
  #
  # @param tolerant [Boolean] <i>(defaults to: +false+)</i>
  #   if true, anything non-sequence is complemented to itself
  # @param rnasequence [Boolean] <i>(defaults to: +false+)</i>
  #   if true, any A and a is complemented into u and U; otherwise
  #   it is so, only if an U is found; otherwise DNA is assumed
  #
  # @raise [RuntimeError] if not +tolerant+ and chars are found for which
  #   no Watson-Crick complement is defined
  # @raise [RuntimeError] if sequence contains both U and T
  #
  # @example
  #  "ACTG".rc  # => "CAGT"
  #  "acGT".rc  # => "ACgt"
  # @example Undefined sequence is represented by "*":
  #  "*".rc     # => "*"
  # @example Extended IUPAC Alphabet:
  #  "ARBN".rc  # => "NVYT"
  # @example Usage with RNA sequences:
  #  "ACUG".rc                    # => "CAGU"
  #  "ACG".rc(rnasequence: true)  # => "CGU"
  #  "ACUT".rc                    # (raises RuntimeError, both U and T)
  def rc(tolerant: false, rnasequence: false)
    return "*" if self == "*"
    retval = each_char.map do |c|
      if c == "U" or c == "u"
        rnasequence = true
      elsif rnasequence and (c == "T" or c == "t")
        raise "String contains both U/u and T/t"
      end
      wcc = WCC.fetch(c, tolerant ? c : nil)
      raise "#{self}: no Watson-Crick complement for #{c}" if wcc.nil?
      wcc
    end.reverse.join
    if rnasequence
      retval.tr!("tT","uU")
    end
    retval
  end

  # Watson-Crick Complements
  WCC = {"a"=>"t","t"=>"a","A"=>"T","T"=>"A",
         "c"=>"g","g"=>"c","C"=>"G","G"=>"C",
         "b"=>"v","B"=>"V","v"=>"b","V"=>"B",
         "h"=>"d","H"=>"D","d"=>"h","D"=>"H",
         "R"=>"Y","Y"=>"R","r"=>"y","y"=>"r",
         "K"=>"M","M"=>"K","k"=>"m","m"=>"k",
         "S"=>"S","s"=>"s","w"=>"w","W"=>"W",
         "n"=>"n","N"=>"N","u"=>"a","U"=>"A",
         "-"=>"-","."=>".","="=>"=",
         " "=>"","\n"=>""}
end

class String
  include RGFA::Sequence
end
