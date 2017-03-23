"""
Methods for processing strings as nucleotidic sequences
"""
import gfapy

def rc(sequence, valid = False, rna = False):
  """Compute the reverse complement of a nucleotidic sequence.

  All characters in the IUPAC extended alphabet are supported
  (ACGTUBVHDRYKMSWN). The character ".-=", spaces and newlines
  are left as they are. The case of each character is preserved.

  Returns
    str : reverse complement, without newlines and spaces;
         	"*" if string is "*"

  Parameters:
    sequence (str) : the sequence to reverse-complement
    valid (bool) : if True, the reverse complement of any invalid character
      is the character itself
    rna (bool) : if True, t/T are substituted by u/U in the output

  Raises:
    gfapy.error.ValueError : if valid is False and an invalid character
      (not in the IUPAC extended alphabet for nucleotide sequences, .-=,
      spaces or newline) is found
  """
  if gfapy.is_placeholder(sequence): return sequence
  def fun(c):
    wcc = WCC.get(c, c if valid else None)
    if not wcc:
      raise gfapy.ValueError("{}: no Watson-Crick complement for {}".format(sequence, c))
    return wcc
  retval = "".join(reversed([ fun(c) for c in sequence ]))
  if rna:
    retval = retval.translate(str.maketrans("tT", "uU"))
  return retval

WCC = {"a":"t","t":"a","A":"T","T":"A",
       "c":"g","g":"c","C":"G","G":"C",
       "b":"v","B":"V","v":"b","V":"B",
       "h":"d","H":"D","d":"h","D":"H",
       "R":"Y","Y":"R","r":"y","y":"r",
       "K":"M","M":"K","k":"m","m":"k",
       "S":"S","s":"s","w":"w","W":"W",
       "n":"n","N":"N","u":"a","U":"A",
       "-":"-",".":".","=":"=",
       " ":"","\n":""}
"""Watson-Crick Complements"""

def Sequence(string):
  """Parses the content of a sequence field.

  Parameters:
    string (str) : content of a sequence field

  Returns:
    str, gfapy.Placeholder : if the string is the placeholder
      symbol ``*`` then a placeholder, otherwise the string
      itself
  """
  return gfapy.Placeholder() if (string == "*") else string
