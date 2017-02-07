import gfapy
import unittest

class TestLinePath(unittest.TestCase):

  def test_from_string(self):
    fields = ["P","4","1+,2-,3+","9M2I3D1M,12M","ab:Z:abcd"]
    string = "\t".join(fields)
    gfapy.Line.from_string(string)
    self.assertIsInstance(gfapy.Line.from_string(string), gfapy.line.group.Path)
    self.assertEqual(str(fields[0]), gfapy.Line.from_string(string).record_type)
    self.assertEqual(str(fields[1]), gfapy.Line.from_string(string).path_name)
    self.assertEqual([gfapy.OrientedLine("1","+"),
                      gfapy.OrientedLine("2","-"),
                      gfapy.OrientedLine("3","+")],
                     gfapy.Line.from_string(string).segment_names)
    self.assertEqual([[gfapy.alignment.cigar.Operation(9,"M"),
                       gfapy.alignment.cigar.Operation(2,"I"),
                       gfapy.alignment.cigar.Operation(3,"D"),
                       gfapy.alignment.cigar.Operation(1,"M")],
                      [gfapy.alignment.cigar.Operation(12,"M")]],
                     gfapy.Line.from_string(string).overlaps)
    self.assertEqual("abcd", gfapy.Line.from_string(string).ab)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line.from_string(string+"\tH1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line.from_string("P\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[2]="1,2,3"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.InconsistencyError):
      f=fields[:]
      f[2]="1+,2+"
      f[3]="9M,12M,3M"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)

    f=fields[:]
    f[3]="*,*"
    gfapy.Line.from_string("\t".join(f), vlevel = 2)

    f=fields[:]
    f[3]="9M2I3D1M,12M,12M"
    gfapy.Line.from_string("\t".join(f), vlevel = 2)

    f=fields[:]
    f[3]="*"
    gfapy.Line.from_string("\t".join(f), vlevel = 2)

    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[3]="12,12"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[3]="12M|12M"
      gfapy.Line.from_string("\t".join(f), vlevel = 2)
