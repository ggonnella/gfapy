import gfapy

def invert(symbol):
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
