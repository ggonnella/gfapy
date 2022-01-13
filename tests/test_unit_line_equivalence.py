import unittest
import gfapy

class TestUnitLineEquivalence(unittest.TestCase):

  a      = gfapy.Line("S\tA\t*\tLN:i:8\txx:Z:a")
  b      = gfapy.Line("S\tB\t*\tLN:i:10")
  c      = gfapy.Line("C\tA\t+\tB\t+\t10\t*")
  l      = gfapy.Line("L\tA\t+\tB\t+\t*")
  e      = gfapy.Line("E\t1\tA+\tB-\t0\t100$\t20\t121\t*")

  a_ln   = gfapy.Line("S\tA\t*\tLN:i:10\txx:Z:a")
  a_seq  = gfapy.Line("S\tA\tACCTTCGT\tLN:i:8\txx:Z:a")
  a_gfa2 = gfapy.Line("S\tA\t8\tACCTTCGT\txx:Z:a")
  a_noxx = gfapy.Line("S\tA\t*\tLN:i:8")
  a_yy   = gfapy.Line("S\tA\t*\tLN:i:8\txx:Z:a\tyy:Z:b")
  l_from = gfapy.Line("L\tC\t+\tB\t+\t*")
  e_name = gfapy.Line("E\t2\tA+\tB-\t0\t100$\t20\t121\t*")

  h_a    = {"record_type": "S",
            "name": "A",
            "LN": 8,
            "xx": "a"}
  h_a_rt = h_a.copy()
  h_a_rt["record_type"] = "X"
  h_a_pl = h_a.copy()
  h_a_pl["name"] = gfapy.Placeholder()
  h_a_name = h_a.copy()
  h_a_name["name"] = "B"
  h_a_seq = h_a.copy()
  h_a_seq["sequence"] = "ACCTTCGT"
  h_a_ln = h_a.copy()
  h_a_ln["LN"] = 10
  h_a_LNstr = h_a.copy()
  h_a_LNstr["LN"] = "8"
  h_a_noxx = h_a.copy()
  h_a_noxx.pop("xx")
  h_a_yy = h_a.copy()
  h_a_yy["yy"] = "b"
  h_a_gfa2 = {"record_type": "S",
              "sid": "A",
              "slen": 8,
              "xx": "a"}


  def test_line_placeholder(self):
    assert(not gfapy.is_placeholder(TestUnitLineEquivalence.a))
    assert(not gfapy.is_placeholder(TestUnitLineEquivalence.b))

  def test_line_diff_two_segments(self):
    adiffb = [("different", "positional_field", "name", "A", "B"),
              ("exclusive", "<", "tag", "xx", "Z", "a"),
              ("different", "tag", "LN", "i", "8", "i", "10")]
    self.assertEqual(sorted(adiffb), sorted(TestUnitLineEquivalence.a.diff(TestUnitLineEquivalence.b)))
    bdiffa = [("different", "positional_field", "name", "B", "A"),
              ("exclusive", ">", "tag", "xx", "Z", "a"),
              ("different", "tag", "LN", "i", "10", "i", "8")]
    self.assertEqual(sorted(bdiffa), sorted(TestUnitLineEquivalence.b.diff(TestUnitLineEquivalence.a)))
    self.assertEqual([], TestUnitLineEquivalence.a.diff(TestUnitLineEquivalence.a))
    self.assertEqual([], TestUnitLineEquivalence.b.diff(TestUnitLineEquivalence.b))

  def test_line_diffscript_two_segments(self):
    acpy = TestUnitLineEquivalence.a.clone()
    exec(acpy.diffscript(TestUnitLineEquivalence.b, "acpy"))
    self.assertNotEqual(str(TestUnitLineEquivalence.b), str(TestUnitLineEquivalence.a))
    self.assertEqual(str(TestUnitLineEquivalence.b), str(acpy))
    bcpy = TestUnitLineEquivalence.b.clone()
    exec(bcpy.diffscript(TestUnitLineEquivalence.a, "bcpy"))
    self.assertNotEqual(str(TestUnitLineEquivalence.a), str(TestUnitLineEquivalence.b))
    self.assertEqual(str(TestUnitLineEquivalence.a), str(bcpy))

  def test_equal(self):
    assert(TestUnitLineEquivalence.a == TestUnitLineEquivalence.a)
    assert(TestUnitLineEquivalence.b == TestUnitLineEquivalence.b)
    assert(TestUnitLineEquivalence.c == TestUnitLineEquivalence.c)
    assert(TestUnitLineEquivalence.l == TestUnitLineEquivalence.l)
    assert(TestUnitLineEquivalence.e == TestUnitLineEquivalence.e)
    assert(not (TestUnitLineEquivalence.a == TestUnitLineEquivalence.b))
    assert(not (TestUnitLineEquivalence.a == TestUnitLineEquivalence.a_ln))
    assert(not (TestUnitLineEquivalence.a == TestUnitLineEquivalence.a_seq))
    assert(not (TestUnitLineEquivalence.a == TestUnitLineEquivalence.a_gfa2))
    assert(not (TestUnitLineEquivalence.a == TestUnitLineEquivalence.a_noxx))
    assert(TestUnitLineEquivalence.b == TestUnitLineEquivalence.b.clone())
    assert(TestUnitLineEquivalence.a == TestUnitLineEquivalence.a.clone())

  def test_pointer_equality(self):
    assert(TestUnitLineEquivalence.a is TestUnitLineEquivalence.a)
    assert(not TestUnitLineEquivalence.a is TestUnitLineEquivalence.a.clone())

  def test_has_eql_fields(self):
    # same object
    assert(TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a))
    # clone
    assert(TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a.clone()))
    # positional field difference
    assert(not TestUnitLineEquivalence.l._has_eql_fields(TestUnitLineEquivalence.l_from))
    assert(TestUnitLineEquivalence.l._has_eql_fields(TestUnitLineEquivalence.l_from,
      ["from_segment"]))
    # positional field difference: name alias
    assert(not TestUnitLineEquivalence.e._has_eql_fields(TestUnitLineEquivalence.e_name))
    assert(TestUnitLineEquivalence.e._has_eql_fields(TestUnitLineEquivalence.e_name, ["eid"]))
    assert(TestUnitLineEquivalence.e._has_eql_fields(TestUnitLineEquivalence.e_name, ["name"]))
    # positional field difference: placeholder in line
    assert(TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a_seq))
    # positional field difference: placeholder in reference
    assert(TestUnitLineEquivalence.a_seq._has_eql_fields(TestUnitLineEquivalence.a))
    # tag difference
    assert(not TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a_ln))
    assert(TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a_ln, ["LN"]))
    # additional tag in line
    assert(TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a_noxx))
    assert(not TestUnitLineEquivalence.a_noxx._has_eql_fields(TestUnitLineEquivalence.a))
    # missing tag in line
    assert(not TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a_yy))
    assert(TestUnitLineEquivalence.a_yy._has_eql_fields(TestUnitLineEquivalence.a))
    assert(TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a_yy, ["yy"]))
    # gfa1 vs gfa2
    assert(TestUnitLineEquivalence.a._has_eql_fields(TestUnitLineEquivalence.a_gfa2, ["slen"]))
    assert(TestUnitLineEquivalence.a_gfa2._has_eql_fields(TestUnitLineEquivalence.a, ["LN"]))
    # record_type
    assert(not TestUnitLineEquivalence.c._has_eql_fields(TestUnitLineEquivalence.l))
    assert(not TestUnitLineEquivalence.l._has_eql_fields(TestUnitLineEquivalence.c))
    assert(TestUnitLineEquivalence.c._has_eql_fields(TestUnitLineEquivalence.l, ["record_type"]))
    assert(TestUnitLineEquivalence.l._has_eql_fields(TestUnitLineEquivalence.c, ["record_type", "pos"]))

  def test_has_field_values(self):
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a))
    # record_type difference
    assert(not TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_rt))
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_rt, ["record_type"]))
    # positional field difference
    assert(not TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_name))
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_name, ["name"]))
    # positional field difference: placeholder in line
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_seq))
    # positional field difference: placeholder in hash is compared
    assert(not TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_pl))
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_pl, ["name"]))
    # tag difference
    assert(not TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_ln))
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_ln, ["LN"]))
    # encoded value
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_LNstr))
    # additional tag in line
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_noxx))
    # missing tag in line
    assert(not TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_yy))
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_yy, ["yy"]))
    # gfa1 vs gfa2
    assert(TestUnitLineEquivalence.a._has_field_values(TestUnitLineEquivalence.h_a_gfa2, ["slen"]))

