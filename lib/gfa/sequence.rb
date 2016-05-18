#
# Extensions of the String class to handle nucleotidic sequences
#
module GFA::Sequence

  # Computes the reverse complement of a nucleotidic sequence.
  #
  # * *Args* :
  #   - +tolerant+ -> if true, anything non-sequence is complemented to itself;
  #                   otherwise an exception is raised
  # * *Raises* :
  #   - +RuntimeError+ if +!tolerant+ and the string contains a character with
  #                    no defined Watson-Crick complement
  # * *Returns* :
  #   - if the string consist of only "*", then "*" is returned
  #   - otherwise: a string containing the reverse complement
  #                and without newlines and spaces
  def rc(tolerant=false)
    return "*" if self == "*"
    each_char.map{|c|c.wcc(tolerant)}.reverse.join
  end

  WCC = {"a"=>"t","t"=>"a","A"=>"T","T"=>"A",
         "c"=>"g","g"=>"c","C"=>"G","G"=>"C",
         "b"=>"v","B"=>"V","v"=>"b","V"=>"B",
         "h"=>"d","H"=>"D","d"=>"h","D"=>"H",
         "R"=>"Y","Y"=>"R","r"=>"y","y"=>"r",
         "K"=>"M","M"=>"K","k"=>"m","m"=>"k",
         "S"=>"S","s"=>"s","w"=>"w","W"=>"W",
         "n"=>"n","N"=>"N","-"=>"-","."=>".",
         "="=>"="," "=>"","\n",""}

  private

  # Watson-Crick complement of base (single-character string)
  #
  # * *Args* :
  #   - +tolerant+ -> if true, anything non-sequence is complemented to itself;
  #                   otherwise an exception is raised
  # * *Raises* :
  #   - +RuntimeError+ if the string contains multiple characters
  #   - +RuntimeError+ if +!tolerant+ and the string contains a character with
  #                    no defined Watson-Crick complement
  # * *Returns* :
  #   - a string of length 1 containing the WC complement, or the character
  #   itself if this is not available, and +tolerant+ is set
  def wcc(tolerant=false)
    raise "String#wcc: string must be a single character (#{self})" \
      if size != 1
    res = WCC[self]
    if res.nil?
      return self if tolerant
      raise "#{self}: no Watson-Crick complement defined"
    else
      return res
    end
  end

end

class String
  include GFA::Sequence
end
