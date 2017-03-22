import gfapy
import unittest

class TestLinePath(unittest.TestCase):

  def test_from_string(self):
    fields = ["P","4","1+,2-,3+","9M2I3D1M,12M","ab:Z:abcd"]
    string = "\t".join(fields)
    gfapy.Line(string)
    self.assertIsInstance(gfapy.Line(string), gfapy.line.group.Path)
    self.assertEqual(str(fields[0]), gfapy.Line(string).record_type)
    self.assertEqual(str(fields[1]), gfapy.Line(string).path_name)
    self.assertEqual([gfapy.OrientedLine("1","+"),
                      gfapy.OrientedLine("2","-"),
                      gfapy.OrientedLine("3","+")],
                     gfapy.Line(string).segment_names)
    self.assertEqual([[gfapy.alignment.cigar.Operation(9,"M"),
                       gfapy.alignment.cigar.Operation(2,"I"),
                       gfapy.alignment.cigar.Operation(3,"D"),
                       gfapy.alignment.cigar.Operation(1,"M")],
                      [gfapy.alignment.cigar.Operation(12,"M")]],
                     gfapy.Line(string).overlaps)
    self.assertEqual("abcd", gfapy.Line(string).ab)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line(string+"\tH1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("P\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[2]="1,2,3"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.InconsistencyError):
      f=fields[:]
      f[2]="1+,2+"
      f[3]="9M,12M,3M"
      gfapy.Line("\t".join(f), vlevel = 2)

    f=fields[:]
    f[3]="*,*"
    gfapy.Line("\t".join(f), vlevel = 2)

    f=fields[:]
    f[3]="9M2I3D1M,12M,12M"
    gfapy.Line("\t".join(f), vlevel = 2)

    f=fields[:]
    f[3]="*"
    gfapy.Line("\t".join(f), vlevel = 2)

    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[3]="12,12"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[3]="12M|12M"
      gfapy.Line("\t".join(f), vlevel = 2)
