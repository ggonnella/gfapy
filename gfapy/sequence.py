"""
Methods for processing strings as nucleotidic sequences
"""
import gfapy

def rc(sequence, valid = False, rna = False):
  """
  Computes the reverse complement of a nucleotidic sequence

  Returns
  -------
  gfapy.String
  	reverse complement, without newlines and spaces
  	"*" if string is "*"

  Parameters
  ----------
  valid : bool
  rna : bool
  sequence : str
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

# Watson-Crick Complements
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

def Sequence(string):
  """
  Parse a string as sequence.

  Parameters
  ----------
  string : str

  Returns
  -------
  gfapy.Placeholder
  	Returns self if the string content is other than "*", 
    otherwise a gfapy.Placeholder object.
  """
  return gfapy.Placeholder() if (string == "*") else string
