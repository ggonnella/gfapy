import gfapy
import unittest

class TestAPIPositionals(unittest.TestCase):

  s = {
    "S1": "S\t1\t*",
    "L": "L\t1\t+\t2\t+\t*",
    "C": "C\t1\t+\t2\t+\t10\t*",
    "P": "P\tx\t1+,2+\t*",
    "S2": "S\t2\t100\t*",
    "E": "E\t*\t1+\t2+\t10\t20\t30\t40\t*",
    "F": "F\t1\t5+\t11\t21\t31\t41\t*",
    "G": "G\t*\t1+\t2+\t1000\t1",
    "U": "U\t*\t1 2 3",
    "O": "O\t*\t1+ 2+ 3+",
  }
  f = {k:v.split("\t") for k, v in s.items()}
  l = {k:gfapy.Line(v) for k, v in s.items()}

  fieldnames = {
    "S1":["name", "sequence"],
    "L" :["from_segment", "from_orient", "to_segment", "to_orient", "overlap"],
    "C" :["from_segment", "from_orient", "to_segment", "to_orient", "pos", "overlap"],
    "P" :["path_name", "segment_names", "overlaps"],
    "S2":["sid", "slen", "sequence"],
    "E" :["eid", "sid1", "sid2", "beg1", "end1", "beg2", "end2", "alignment"],
    "F" :["sid", "external", "s_beg", "s_end", "f_beg", "f_end", "alignment"],
    "G" :["gid", "sid1", "sid2", "disp", "var"],
    "U" :["pid", "items"],
    "O" :["pid", "items"],
  }

  # alternative values to set tests
  v1 = {
    "S1":{"name":"sx", "sequence":"accg"},
    "L":{"from_segment":"a1", "from_orient":"-", "to_segment":"a2", "to_orient":"-",
           "overlap": gfapy.Alignment("12M")},
    "C":{"from_segment":"cx", "from_orient":"-", "to_segment":"cy", "to_orient":"-",
           "pos":123, "overlap": gfapy.Alignment("120M")},
    "P":{"path_name":"px", "segment_names":[gfapy.OrientedLine("x","+"), gfapy.OrientedLine("y","-")],
           "overlaps":[gfapy.Alignment("10M")]},
    "S2":{"sid":"s2s", "slen":999, "sequence":"gggg"},
    "E" :{"eid":"e2e", "sid1":gfapy.OrientedLine("s2s","-"),
            "sid2":gfapy.OrientedLine("t2t","-"),
            "beg1":0, "end1":gfapy.LastPos("100$"),
            "beg2":10, "end2":gfapy.LastPos("110$"),
            "alignment":gfapy.Alignment("10M1I10M1D80M")},
    "F" :{"sid":"s2s", "external":gfapy.OrientedLine("ex2ex","-"),
            "s_beg":0, "s_end":gfapy.LastPos("100$"),
            "f_beg":10, "f_end":gfapy.LastPos("110$"),
            "alignment":gfapy.Alignment("10M1I10M1D80M")},
    "G" :{"gid":"g2g", "sid1":gfapy.OrientedLine("s2s","+"), "sid2":gfapy.OrientedLine("t2t","-"),
            "disp":2000, "var":100},
    "O" :{"pid":"O100", "items":[gfapy.OrientedLine("x1","+"),
                                      gfapy.OrientedLine("x2","+"),
                                      gfapy.OrientedLine("x3","-")]},
    "U" :{"pid":"U100", "items":["x1", "x2", "x3"]},
  }
  v2 = {
    "S1":{"name":"xs", "sequence":"aggc"},
    "L":{"from_segment":"a5", "from_orient":"+", "to_segment":"a7", "to_orient":"+",
           "overlap":gfapy.Alignment("9M3I3M")},
    "C":{"from_segment":"cp", "from_orient":"+", "to_segment":"cl", "to_orient":"+",
           "pos":213, "overlap":gfapy.Alignment("110M4D10M")},
    "P":{"path_name":"pu", "segment_names":[gfapy.OrientedLine("k","-"),
           gfapy.OrientedLine("l","+")], "overlaps":[gfapy.Alignment("11M")]},
    "S2":{"sid":"s4s", "slen":1999, "sequence":"aaaa"},
    "E" :{"eid":"e4e", "sid1":gfapy.OrientedLine("s4s","+"),
            "sid2":gfapy.OrientedLine("t4t","+"),
            "beg1":10, "end1":gfapy.LastPos("110$"),
            "beg2":0, "end2":gfapy.LastPos("100$"),
            "alignment":gfapy.Alignment("10M1I20M1D80M")},
    "F" :{"sid":"s4s", "external":gfapy.OrientedLine("ex4ex", "+"),
            "s_beg":10, "s_end":gfapy.LastPos("110$"),
            "f_beg":0, "f_end":gfapy.LastPos("100$"),
            "alignment":gfapy.Alignment("10M1I20M1D80M")},
    "G" :{"gid":"g4g", "sid1":gfapy.OrientedLine("s4s","-"), "sid2":gfapy.OrientedLine("t4t","+"),
            "disp":3000, "var":200},
    "O" :{"pid":"O200", "items":[gfapy.OrientedLine("x7","-"),
                                      gfapy.OrientedLine("x6","+"),
                                      gfapy.OrientedLine("x3","+")]},
    "U" :{"pid":"U200", "items":["x6", "x7", "x4"]},
  }
  aliases = {
      "S1":{"name":"sid"}, "P":{"path_name":"name"},
      "S2":{"sid":"name"}, "E":{"eid":"name"}, "G":{"gid":"name"},
      "U":{"pid":"name"}, "O":{"pid":"name"},
      "C":{"from_segment":"container", "from_orient":"container_orient",
             "to_segment":"contained", "to_orient":"contained_orient"}
  }

  def test_number_of_positionals(self):
    for rt, fields in TestAPIPositionals.f.items():
      gfapy.Line(fields) # nothing raised
      too_less = fields.copy(); too_less.pop()
      with self.assertRaises(gfapy.FormatError): gfapy.Line(too_less)
      too_many = fields.copy(); too_many.append("*")
      with self.assertRaises(gfapy.FormatError): gfapy.Line(too_many)

  def test_positional_fieldnames(self):
    for rt, line in TestAPIPositionals.l.items():
      self.assertEqual(TestAPIPositionals.fieldnames[rt], line.positional_fieldnames)

  def test_field_getters_and_setters(self):
    for rt, fn_list in TestAPIPositionals.fieldnames.items():
      for i, fn in enumerate(fn_list):
        i+=1 # skip record_type
        # field_to_s()
        self.assertEqual(TestAPIPositionals.f[rt][i], TestAPIPositionals.l[rt].field_to_s(fn))
        # validate_field/validate
        TestAPIPositionals.l[rt].validate_field(fn) # nothing raised
        TestAPIPositionals.l[rt].validate # nothing raised
        # fieldname() == get(fieldname)
        self.assertEqual(getattr(TestAPIPositionals.l[rt], fn), TestAPIPositionals.l[rt].get(fn))
        # fieldname=() and fieldname()
        l = TestAPIPositionals.l[rt].clone()
        setattr(l,fn,TestAPIPositionals.v1[rt][fn])
        self.assertEqual(TestAPIPositionals.v1[rt][fn], getattr(l, fn))
        # set() and get()
        l.set(fn, TestAPIPositionals.v2[rt][fn])
        self.assertEqual(TestAPIPositionals.v2[rt][fn], l.get(fn))

  def test_aliases(self):
    for rt, aliasmap in TestAPIPositionals.aliases.items():
      for orig, al in aliasmap.items():
        # get(orig) == get(alias)
        self.assertEqual(getattr(TestAPIPositionals.l[rt], orig), getattr(TestAPIPositionals.l[rt],al))
        self.assertEqual(TestAPIPositionals.l[rt].get(orig), TestAPIPositionals.l[rt].get(al))
        # validate_field/validate
        TestAPIPositionals.l[rt].validate_field(al) # nothing raised
        TestAPIPositionals.l[rt].validate # nothing raised
        # field_to_s(orig) == field_to_s(alias)
        self.assertEqual(TestAPIPositionals.l[rt].field_to_s(orig), TestAPIPositionals.l[rt].field_to_s(al))
        # set(al, value) + get(orig)
        l = TestAPIPositionals.l[rt].clone()
        self.assertNotEqual(TestAPIPositionals.v1[rt][orig], getattr(l,orig))
        l.set(al, TestAPIPositionals.v1[rt][orig])
        self.assertEqual(TestAPIPositionals.v1[rt][orig], getattr(l,orig))
        # alias=value + orig()
        self.assertNotEqual(TestAPIPositionals.v2[rt][orig], getattr(l,orig))
        setattr(l, al, TestAPIPositionals.v2[rt][orig])
        self.assertEqual(TestAPIPositionals.v2[rt][orig], getattr(l,orig))
        # set(orig, value) + get(alias)
        self.assertNotEqual(TestAPIPositionals.v1[rt][orig], getattr(l,al))
        l.set(orig, TestAPIPositionals.v1[rt][orig])
        self.assertEqual(TestAPIPositionals.v1[rt][orig], getattr(l,al))
        # orig=value + alias()
        self.assertNotEqual(TestAPIPositionals.v2[rt][orig], getattr(l,al))
        setattr(l, orig, TestAPIPositionals.v2[rt][orig])
        self.assertEqual(TestAPIPositionals.v2[rt][orig], getattr(l,al))

  def test_array_fields(self):
    assert(isinstance(TestAPIPositionals.l["P"].segment_names, list))
    assert(isinstance(TestAPIPositionals.l["P"].segment_names[0], gfapy.OrientedLine))
    assert(isinstance(TestAPIPositionals.l["P"].overlaps, list))
    assert(isinstance(TestAPIPositionals.l["P"].overlaps[0], gfapy.AlignmentPlaceholder))
    assert(isinstance(TestAPIPositionals.l["O"].items, list))
    assert(isinstance(TestAPIPositionals.l["O"].items[0], gfapy.OrientedLine))
    assert(isinstance(TestAPIPositionals.l["U"].items, list))
    assert(isinstance(TestAPIPositionals.l["U"].items[0], str))

  def test_orientation(self):
    # orientation is symbol
    self.assertEqual("+", TestAPIPositionals.l["L"].from_orient)
    self.assertEqual("+", TestAPIPositionals.l["L"].to_orient)
    # invert
    self.assertEqual("-", gfapy.invert(TestAPIPositionals.l["L"].to_orient))
    self.assertEqual("+", gfapy.invert("-"))
    self.assertEqual("-", gfapy.invert("+"))
    # string representation
    self.assertEqual("+", TestAPIPositionals.l["L"].field_to_s("from_orient"))
    # assigning the string representation
    l = TestAPIPositionals.l["L"].clone()
    l.from_orient = "+"
    self.assertEqual("+", l.from_orient)
    self.assertEqual("-", gfapy.invert(l.from_orient))
    # non "+"/"-" symbols is an error
    with self.assertRaises(gfapy.FormatError):
      l.from_orient = "x"
      l.validate()
    # only "+"/"-" and their string representations are accepted
    with self.assertRaises(gfapy.FormatError):
      l.from_orient = "x"
      l.validate()
    with self.assertRaises(gfapy.FormatError):
      l.from_orient = 1
      l.validate()

  def test_oriented_segment(self):
    os = TestAPIPositionals.l["P"].segment_names[0]
    # getter methods
    self.assertEqual("1", os.line)
    self.assertEqual("+", os.orient)
    # invert
    self.assertEqual("1", os.inverted().line)
    self.assertEqual("-", os.inverted().orient)
    self.assertEqual("-", gfapy.invert(os.orient))
    # setter methods
    os.line = "one"
    os.orient = "-"
    self.assertEqual("one", os.line)
    self.assertEqual("-", os.orient)
    # name
    self.assertEqual("one", os.name)
    os.line = TestAPIPositionals.l["S1"]
    self.assertEqual(TestAPIPositionals.l["S1"], os.line)
    self.assertEqual(TestAPIPositionals.l["S1"].name, os.name)

  def test_sequence(self):
    # placeholder
    assert(gfapy.is_placeholder(TestAPIPositionals.l["S1"].sequence))
    assert(gfapy.is_placeholder(TestAPIPositionals.l["S2"].sequence))
    s = TestAPIPositionals.l["S1"].clone()
    s.sequence = "ACCT"
    assert(not gfapy.is_placeholder(s.sequence))
    # sequence is string
    self.assertEqual("ACCT", s.sequence)
    # rc
    self.assertEqual("AGGT", gfapy.sequence.rc(s.sequence))
    # GFA2 allowed alphabet is larger than GFA1
    s.validate # nothing raised
    s.sequence = ";;;{}"
    with self.assertRaises(gfapy.FormatError): s.validate()
    s = TestAPIPositionals.l["S2"].clone()
    s.sequence = ";;;{}"
    s.validate() # nothing raised
    # Sequence
    assert(isinstance(gfapy.sequence.Sequence("*"),gfapy.Placeholder))
    assert(isinstance(gfapy.sequence.Sequence("ACG"),str))

  def test_sequence_rc(self):
    self.assertEqual("gcatcgatcgt",gfapy.sequence.rc("acgatcgatgc"))
    # case
    self.assertEqual("gCaTCgatcgt",gfapy.sequence.rc("acgatcGAtGc"))
    # wildcards
    self.assertEqual("gcatcnatcgt",gfapy.sequence.rc("acgatngatgc"))
    self.assertEqual("gcatcYatcgt",gfapy.sequence.rc("acgatRgatgc"))
    # RNA
    self.assertEqual("gcaucgaucgu",gfapy.sequence.rc("acgaucgaugc",rna=True))
    self.assertEqual("===.",gfapy.sequence.rc(".==="))
    # valid
    with self.assertRaises(gfapy.ValueError): gfapy.sequence.rc("acgatXgatgc")
    gfapy.sequence.rc("acgatXgatgc",valid=True) # nothing raised
    # placeholder
    self.assertEqual("*",gfapy.sequence.rc("*"))
    with self.assertRaises(gfapy.ValueError): gfapy.sequence.rc("**")

