import unittest
import gfapy

class TestUnitSegmentEnd(unittest.TestCase):

  sym = "a"
  ref = gfapy.Line("S\ta\t*\txx:Z:1.0")
  invalid_sym = "a\ta"
  invalid_ref = []
  se_s = gfapy.SegmentEnd(sym, "L")
  se_r = gfapy.SegmentEnd(ref, "R")
  se_s_str = "aL"
  se_r_str = "aR"
  se_s_sym = "aL"
  se_r_sym = "aR"

  def test_new(self):
    gfapy.SegmentEnd(TestUnitSegmentEnd.sym, "L")
    # no validation on creation
    gfapy.SegmentEnd(TestUnitSegmentEnd.invalid_sym, "X")

  def test_from_list(self):
    self.assertEqual(TestUnitSegmentEnd.se_s,
        gfapy.SegmentEnd(["a", "L"]))
    self.assertEqual(gfapy.SegmentEnd,
        gfapy.SegmentEnd(["a", "L"]).__class__)
    self.assertRaises(gfapy.ArgumentError, gfapy.SegmentEnd,
      ["a", "L", "L"])
    gfapy.SegmentEnd(["a", "X"]) # no validation

  def test_segment(self):
    self.assertEqual(TestUnitSegmentEnd.sym, TestUnitSegmentEnd.se_s.segment)
    self.assertEqual(TestUnitSegmentEnd.ref, TestUnitSegmentEnd.se_r.segment)
    se2 = gfapy.SegmentEnd(TestUnitSegmentEnd.sym, "R")
    se2.segment = TestUnitSegmentEnd.ref
    self.assertEqual(TestUnitSegmentEnd.ref, se2.segment)

  def test_end_type(self):
    self.assertEqual("L", TestUnitSegmentEnd.se_s.end_type)
    self.assertEqual("R", TestUnitSegmentEnd.se_r.end_type)
    se2 = gfapy.SegmentEnd(TestUnitSegmentEnd.sym, "L")
    se2.end_type = "R"
    self.assertEqual("R", se2.end_type)

  def test_name(self):
    self.assertEqual(TestUnitSegmentEnd.sym, TestUnitSegmentEnd.se_s.name)
    self.assertEqual(TestUnitSegmentEnd.sym, TestUnitSegmentEnd.se_r.name)

  def test_validate(self):
    TestUnitSegmentEnd.se_s.validate()
    TestUnitSegmentEnd.se_r.validate()
    se1 = gfapy.SegmentEnd("a", "X")
    self.assertRaises(gfapy.ValueError, se1.validate)

  def test_inverted(self):
    inv_s = TestUnitSegmentEnd.se_s.inverted()
    self.assertEqual(TestUnitSegmentEnd.se_s.segment, inv_s.segment)
    self.assertEqual("R", inv_s.end_type)
    inv_r = TestUnitSegmentEnd.se_r.inverted()
    self.assertEqual(TestUnitSegmentEnd.se_r.segment, inv_r.segment)
    self.assertEqual("L", inv_r.end_type)

  def test_to_s(self):
    self.assertEqual(TestUnitSegmentEnd.se_s_str, str(TestUnitSegmentEnd.se_s))
    self.assertEqual(TestUnitSegmentEnd.se_r_str, str(TestUnitSegmentEnd.se_r))

  def test_equal(self):
    se2 = gfapy.SegmentEnd(TestUnitSegmentEnd.sym, "L")
    se3 = gfapy.SegmentEnd(TestUnitSegmentEnd.ref, "R")
    self.assertEqual(TestUnitSegmentEnd.se_s, se2)
    self.assertEqual(TestUnitSegmentEnd.se_r, se3)
    # only name and end_type equivalence is checked, not segment
    assert(TestUnitSegmentEnd.se_r != TestUnitSegmentEnd.se_s)
    assert(TestUnitSegmentEnd.se_r.inverted() == TestUnitSegmentEnd.se_s)
    # equivalence to array
    assert(TestUnitSegmentEnd.se_s == ["a","L"])
    assert(TestUnitSegmentEnd.se_r == ["a","R"])

  #def test_comparison(self):
  #  self.assertEqual(-1, ["a","L"].to_segment_end() <=> ["b","L"].to_segment_end())
  #  self.assertEqual(0,  ["a","L"].to_segment_end() <=> ["a","L"].to_segment_end())
  #  self.assertEqual(1,  ["b","L"].to_segment_end() <=> ["a","L"].to_segment_end())
  #  self.assertEqual(-1, ["a","L"].to_segment_end() <=> ["a","R"].to_segment_end())
  #  self.assertEqual(0,  ["a","R"].to_segment_end() <=> ["a","R"].to_segment_end())
  #  self.assertEqual(1,  ["a","R"].to_segment_end() <=> ["a","L"].to_segment_end())

  def test_segment_ends_path(self):
    sep = gfapy.SegmentEndsPath([gfapy.SegmentEnd("a","L"),
                                 gfapy.SegmentEnd("b","R")])
    self.assertEqual([gfapy.SegmentEnd("b","L"),gfapy.SegmentEnd("a","R")],
      list(reversed(sep)))
    self.assertNotEqual([gfapy.SegmentEnd("b","L"),gfapy.SegmentEnd("a","R")],
      sep)
    sep.reverse()
    self.assertEqual([gfapy.SegmentEnd("b","L"),gfapy.SegmentEnd("a","R")],
      sep)
