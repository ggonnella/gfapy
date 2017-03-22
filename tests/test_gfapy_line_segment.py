import gfapy
import unittest

class TestLineSegment(unittest.TestCase):

  def test_from_string(self):
    fields = ["S","1","ACGTCACANNN","RC:i:1232","LN:i:11","ab:Z:abcd",
            "FC:i:2321","KC:i:1212"]
    string = "\t".join(fields)
    gfapy.Line(string)
    self.assertIsInstance(gfapy.Line(string), gfapy.line.segment.GFA1)
    self.assertEqual(str(fields[0]), gfapy.Line(string).record_type)
    self.assertEqual(str(fields[1]), gfapy.Line(string).name)
    self.assertEqual(fields[2], gfapy.Line(string).sequence)
    self.assertEqual(1232, gfapy.Line(string).RC)
    self.assertEqual(11, gfapy.Line(string).LN)
    self.assertEqual(2321, gfapy.Line(string).FC)
    self.assertEqual(1212, gfapy.Line(string).KC)
    self.assertEqual("abcd", gfapy.Line(string).ab)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line(string + "\tH1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("S\tH")
    with self.assertRaises(gfapy.FormatError):
      f = fields[:]
      f[2]="!@#?"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.TypeError):
      f=fields[:]
      f[3]="RC:Z:1232"
      gfapy.Line("\t".join(f), version = "gfa1")
    f=["S","2","ACGTCACANNN","LN:i:3"]
    with self.assertRaises(gfapy.InconsistencyError):
      gfapy.Line("\t".join(f), version = "gfa1", vlevel = 2)
    f=["S","2","ACGTCACANNN","LN:i:11"]
    gfapy.Line("\t".join(f))
    f=["S","2","*","LN:i:3"]
    gfapy.Line("\t".join(f))

  def test_forbidden_segment_names(self):
    gfapy.Line("S\tA+B\t*")
    gfapy.Line("S\tA-B\t*")
    gfapy.Line("S\tA,B\t*")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("S\tA+,B\t*", vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("S\tA-,B\t*", vlevel = 2)

  def test_coverage(self):
    l = gfapy.Line("S\t0\t*\tRC:i:600\tLN:i:100")
    self.assertEqual(6, l.coverage())
    self.assertEqual(6, l.try_get_coverage())
    l = gfapy.Line("S\t0\t*\tRC:i:600")
    self.assertEqual(None, l.coverage())
    self.assertRaises(gfapy.NotFoundError, l.try_get_coverage)
    l = gfapy.Line("S\t0\t*\tLN:i:100")
    self.assertEqual(None, l.coverage())
    self.assertRaises(gfapy.NotFoundError, l.try_get_coverage)
    l = gfapy.Line("S\t0\t*\tFC:i:600\tLN:i:100")
    self.assertEqual(None, l.coverage())
    self.assertRaises(gfapy.NotFoundError, l.try_get_coverage)
    self.assertEqual(6, l.coverage(count_tag = "FC"))
    self.assertEqual(6, l.try_get_coverage(count_tag = "FC"))
