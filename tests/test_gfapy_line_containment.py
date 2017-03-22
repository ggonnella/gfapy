import unittest
import gfapy

class TestLineContainment(unittest.TestCase):

  def test_from_string(self):
    fields = ["C","1","+","2","-","12","12M","MQ:i:1232","NM:i:3","ab:Z:abcd"]
    string="\t".join(fields)
    gfapy.Line(string)
    self.assertIsInstance(gfapy.Line(string), gfapy.line.edge.Containment)
    self.assertEqual(fields[0], gfapy.Line(string).record_type)
    self.assertEqual(fields[1], gfapy.Line(string).from_segment)
    self.assertEqual(fields[2], gfapy.Line(string).from_orient)
    self.assertEqual(fields[3], gfapy.Line(string).to_segment)
    self.assertEqual(fields[4], gfapy.Line(string).to_orient)
    self.assertEqual(12, gfapy.Line(string).pos)
    self.assertEqual([gfapy.alignment.cigar.CIGAR.Operation(12, "M")],
                     gfapy.Line(string).overlap)
    self.assertEqual(1232, gfapy.Line(string).MQ)
    self.assertEqual(3, gfapy.Line(string).NM)
    self.assertEqual("abcd", gfapy.Line(string).ab)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line(string+"\tH1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line(string+"\tH1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("C\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[2]="x"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[4]="x"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[5]="x"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[6]="x"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.TypeError):
      f=fields[:]
      f[7]="MQ:Z:1232"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.TypeError):
      f=fields[:]
      f[8]="NM:Z:1232"
      gfapy.Line("\t".join(f), vlevel = 2)
