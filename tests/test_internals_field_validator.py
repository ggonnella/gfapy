import gfapy
import unittest

class TestInternalsFieldValidator(unittest.TestCase):

  def test_field_gfa_field_validate_i(self):
    gfapy.Field._validate_gfa_field("1"  , "i")
    gfapy.Field._validate_gfa_field("12" , "i")
    gfapy.Field._validate_gfa_field("-12", "i")
    self.assertRaises(gfapy.FormatError, gfapy.Field._validate_gfa_field, "1A", "i")
    self.assertRaises(gfapy.FormatError, gfapy.Field._validate_gfa_field, "A1", "i")
    self.assertRaises(gfapy.FormatError, gfapy.Field._validate_gfa_field, "2.1", "i")

  def test_field_gfa_field_validate_A(self):
    gfapy.Field._validate_gfa_field("A", "A")
    self.assertRaises(gfapy.FormatError, gfapy.Field._validate_gfa_field, "AA", "A")

  def test_field_gfa_field_validate_f(self):
    gfapy.Field._validate_gfa_field("-12.1", "f")
    gfapy.Field._validate_gfa_field("-12.1E-2", "f")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._validate_gfa_field("2.1X", "f")

  def test_field_gfa_field_validate_Z(self):
    gfapy.Field._validate_gfa_field("-12.1E-2", "Z")

  def test_field_gfa_field_validate_H(self):
    gfapy.Field._validate_gfa_field("0A12121EFF", "H")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._validate_gfa_field("21X1", "H")

  def test_field_gfa_field_validate_B(self):
    gfapy.Field._validate_gfa_field("i,12,-5", "B")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._validate_gfa_field("C,X1", "B")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._validate_gfa_field("f.1.1", "B")

  def test_field_gfa_field_validate_J(self):
    gfapy.Field._validate_gfa_field("{\"1\":2}", "J")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Field._validate_gfa_field("1\t2", "J")
