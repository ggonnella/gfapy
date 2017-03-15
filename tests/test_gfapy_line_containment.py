import unittest
import gfapy

class TestLineContainment(unittest.TestCase):

  def test_from_string(self):
    fields = ["C","1","+","2","-","12","12M","MQ:i:1232","NM:i:3","ab:Z:abcd"]
    string="\t".join(fields)
    gfapy.Line.from_string(string)
    self.assertIsInstance(gfapy.Line.from_string(string), gfapy.line.edge.Containment)
    self.assertEqual(fields[0], gfapy.Line.from_string(string).record_type)
    self.assertEqual(fields[1], gfapy.Line.from_string(string).from_segment)
    self.assertEqual(fields[2], gfapy.Line.from_string(string).from_orient)
    self.assertEqual(fields[3], gfapy.Line.from_string(string).to_segment)
    self.assertEqual(fields[4], gfapy.Line.from_string(string).to_orient)
    self.assertEqual(12, gfapy.Line.from_string(string).pos)
    self.assertEqual([gfapy.alignment.cigar.CIGAR.Operation(12, "M")],
                     gfapy.Line.from_string(string).overlap)
    self.assertEqual(1232, gfapy.Line.from_string(string).MQ)
    self.assertEqual(3, gfapy.Line.from_string(string).NM)
    self.assertEqual("abcd", gfapy.Line.from_string(string).ab)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line.from_string(string+"\tH1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line.from_string(string+"\tH1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line.from_string("C\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[2]="x"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[4]="x"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[5]="x"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[6]="x"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.TypeError):
      f=fields[:]
      f[7]="MQ:Z:1232"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.TypeError):
      f=fields[:]
      f[8]="NM:Z:1232"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
