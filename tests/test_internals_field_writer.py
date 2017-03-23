import gfapy
import unittest

class TestInternalsFieldWriter(unittest.TestCase):
  def test_field_writer_i(self):
    self.assertEqual("13", gfapy.Field._to_gfa_field(13))

  def test_field_writer_f(self):
    self.assertEqual("1.3", gfapy.Field._to_gfa_field(1.3))

  def test_field_writer_Z(self):
    self.assertEqual("1B", gfapy.Field._to_gfa_field("1B"))

  def test_field_writer_H(self):
    self.assertEqual("0D0D0D",
                      gfapy.Field._to_gfa_field(gfapy.ByteArray([13,13,13])))
    with self.assertRaises(gfapy.ValueError):
      gfapy.Field._to_gfa_field(gfapy.ByteArray([13,13,1.3]))
    with self.assertRaises(gfapy.ValueError):
      gfapy.Field._to_gfa_field(gfapy.ByteArray([13,13,350]))

  def test_field_writer_B(self):
    self.assertEqual("C,13,13,13", gfapy.Field._to_gfa_field([13,13,13]))
    self.assertEqual("f,1.3,1.3,1.3", gfapy.Field._to_gfa_field([1.3,1.3,1.3]))
    with self.assertRaises(gfapy.ValueError):
      gfapy.Field._to_gfa_field([13,1.3,1.3], "B")

  def test_field_writer_J(self):
    self.assertEqual("[\"A\", 12]", gfapy.Field._to_gfa_field(["A", 12]))
    self.assertEqual("{\"A\": 12}", gfapy.Field._to_gfa_field({"A" : 12}))

  def test_field_writer_as_tag(self):
    self.assertEqual("AA:i:13", gfapy.Field._to_gfa_tag(13, "AA"))
