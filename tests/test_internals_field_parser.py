import gfapy
import unittest

class TestInternalsFieldParser(unittest.TestCase):

  def test_parse_gfa_tag(self):
    o = "AA:i:1"
    self.assertEqual(["AA","i","1"], gfapy.Field._parse_gfa_tag(o))
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._parse_gfa_tag("1A:A:A")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._parse_gfa_tag("_A:A:A")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._parse_gfa_tag("A:A:A")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._parse_gfa_tag("AAA:A:A")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._parse_gfa_tag("AA:C:1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._parse_gfa_tag("AA:AA:1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._parse_gfa_tag("AA:a:1")

  def test_parse_gfa_field_A(self):
    self.assertEqual("1", gfapy.Field._parse_gfa_field("1", "A"))

  def test_parse_gfa_field_i(self):
    self.assertEqual(12, gfapy.Field._parse_gfa_field("12", "i"))

  def test_parse_gfa_field_f(self):
    self.assertEqual(1.2, gfapy.Field._parse_gfa_field("1.2", "f"))

  def test_parse_gfa_field_Z(self):
    self.assertEqual("1.2", gfapy.Field._parse_gfa_field("1.2", "Z"))

  def test_parse_gfa_field_H(self):
    self.assertEqual(gfapy.ByteArray([26]),
        gfapy.Field._parse_gfa_field("1A", "H"))

  def test_parse_gfa_field_B(self):
    self.assertEqual([12,12,12],
        gfapy.Field._parse_gfa_field("c,12,12,12", "B"))
    self.assertEqual([1.2,1.2,1.2],
        gfapy.Field._parse_gfa_field("f,1.2,1.2,1.2", "B"))

  def test_parse_gfa_field_J(self):
    self.assertEqual({"1" : 2},
        gfapy.Field._parse_gfa_field("{\"1\":2}", "J"))
