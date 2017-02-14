import gfapy
import unittest

class TestApiGFA2Lines(unittest.TestCase):

  def test_S(self):
    fields=["S","1","ACGTCACANNN","RC:i:1232","LN:i:11","ab:Z:abcd",
            "FC:i:2321","KC:i:1212"]
    s="\t".join(fields)
    gfapy.Line.from_string(s) # nothing raised
    self.assertEqual(gfapy.line.segment.GFA1, gfapy.Line.from_string(s).__class__)
    self.assertEqual(fields[0], gfapy.Line.from_string(s).record_type)
    self.assertEqual(fields[1], gfapy.Line.from_string(s).name)
    self.assertEqual(fields[2], gfapy.Line.from_string(s).sequence)
    self.assertEqual(1232, gfapy.Line.from_string(s).RC)
    self.assertEqual(11, gfapy.Line.from_string(s).LN)
    self.assertEqual(2321, gfapy.Line.from_string(s).FC)
    self.assertEqual(1212, gfapy.Line.from_string(s).KC)
    self.assertEqual("abcd", gfapy.Line.from_string(s).ab)
    with self.assertRaises(gfapy.FormatError): s+gfapy.Line.from_string("\tH1")
    with self.assertRaises(gfapy.FormatError): gfapy.Line.from_string("S\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[2]="!@#?"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.TypeError):
      f=fields.copy(); f[3]="RC:Z:1232"; gfapy.Line.from_string("\t".join(f),version="gfa1")
    f=["S","2","ACGTCACANNN","LN:i:3"]
    with self.assertRaises(gfapy.InconsistencyError):
      gfapy.Line.from_string("\t".join(f),vlevel=1, version="gfa1")
    f=["S","2","ACGTCACANNN","LN:i:11"]
    gfapy.Line.from_string("\t".join(f)) # nothing raised
    f=["S","2","*","LN:i:3"]
    gfapy.Line.from_string("\t".join(f)) # nothing raised

  def test_coverage(self):
    l = gfapy.Line.from_string("S\t0\t*\tRC:i:600\tLN:i:100")
    self.assertEqual(6, l.coverage())
    self.assertEqual(6, l.try_get_coverage())
    l = gfapy.Line.from_string("S\t0\t*\tRC:i:600")
    self.assertEqual(None, l.coverage())
    with self.assertRaises(gfapy.NotFoundError): l.try_get_coverage()
    l = gfapy.Line.from_string("S\t0\t*\tLN:i:100")
    self.assertEqual(None, l.coverage())
    with self.assertRaises(gfapy.NotFoundError): l.try_get_coverage()
    l = gfapy.Line.from_string("S\t0\t*\tFC:i:600\tLN:i:100")
    self.assertEqual(None, l.coverage())
    with self.assertRaises(gfapy.NotFoundError): l.try_get_coverage()
    self.assertEqual(6, l.coverage(count_tag="FC"))
    self.assertEqual(6, l.try_get_coverage(count_tag="FC"))

