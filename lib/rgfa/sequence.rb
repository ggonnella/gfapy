require_relative "error"

#
# Extensions of the String class to handle nucleotidic sequences
#
module RGFA::Sequence

  # Computes the reverse complement of a nucleotidic sequence
  #
  # @return [String] reverse complement, without newlines and spaces
  # @return [String] "*" if string is "*"
  #
  # @param valid [Boolean] <i>(defaults to: +false+)</i>
  #   if true, anything non-sequence is complemented to itself
  # @param rna [Boolean] <i>(defaults to: +false+)</i>
  #   if true, any A and a is complemented into u and U
  #
  # @raise [RGFA::ValueError] if chars are found for which
  #   no Watson-Crick complement is defined (and not +valid+)
  #
  # @example
  #  "ACTG".rc  # => "CAGT"
  #  "acGT".rc  # => "ACgt"
  # @example Undefined sequence is represented by "*":
  #  "*".rc     # => "*"
  # @example Extended IUPAC Alphabet:
  #  "ARBN".rc  # => "NVYT"
  # @example Usage with RNA sequences:
  #  "ACG".rc(rna: true) # => "CGU"
  def rc(valid: false, rna: false)
    return self if self.placeholder?
    retval = each_char.map do |c|
      wcc = WCC.fetch(c, valid ? c : nil)
      if wcc.nil?
        raise RGFA::ValueError,
          "#{self}: no Watson-Crick complement for #{c}"
      end
      wcc
    end.reverse.join
    retval.tr!("tT","uU") if rna
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

  # Parse a string as sequence.
  # @return [RGFA::Placeholder, self] returns self if the string content
  #   is other than "*", otherwise a RGFA::Placeholder object
  def to_sequence
    self.placeholder? ? RGFA::Placeholder.new : self
  end
end

class String
  include RGFA::Sequence
end
