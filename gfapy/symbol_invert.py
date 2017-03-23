import gfapy

def invert(symbol):
  """Computes the inverted orientation or end_type symbol.

  Parameters:
    symbol (str) : a one-character string, symbolizing an orientation (+ or -)
      or an end-type (L or R)

  Returns:
    str : the other one character string of the same category (e.g. - for +)

  Raises:
    gfapy.error.ValueError : if a string other than the mentioned ones is used
  """
  if symbol == "+":
    return "-"
  elif symbol == "-":
    return "+"
  elif symbol == "L":
    return "R"
  elif symbol == "R":
    return "L"
  else:
    raise gfapy.ValueError("No inverse defined for {}".format(symbol))
