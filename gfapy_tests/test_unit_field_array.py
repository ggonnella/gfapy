import unittest
import gfapy

class TestUnitFieldArray(unittest.TestCase):

  def test_initialize(self):
    a = gfapy.FieldArray("i", [1,2,3])
    # from a FieldArray:
    z = gfapy.FieldArray("Z", a)
    # no validations by default:
    gfapy.FieldArray("i", [1,2,"a"])
    gfapy.FieldArray("wrong", [1,2])

  def test_datatype(self):
    fa = gfapy.FieldArray("i", [1,2,3])
    self.assertEqual("i", fa.datatype)

  def test_validate(self):
    f1 = gfapy.FieldArray("i", [1,2,3])
    f2 = gfapy.FieldArray("i", [1,2,"a"])
    f3 = gfapy.FieldArray("wrong", [1,2])
    f1.validate()
    self.assertRaises(gfapy.FormatError, f2.validate)
    self.assertRaises(gfapy.TypeError, f3.validate)

  def test_validate_gfa_field(self):
    gfapy.FieldArray("i", [1,2,3])._validate_gfa_field("i")
    self.assertRaises(gfapy.TypeError,
        gfapy.FieldArray("i", [1,2,3])._validate_gfa_field, "J")
    self.assertRaises(gfapy.FormatError,
        gfapy.FieldArray("i", [1,2,"a"])._validate_gfa_field, "i")
    gfapy.FieldArray("wrong", [1,2])._validate_gfa_field("i")

  def test_to_gfa_field(self):
    f = gfapy.FieldArray("i", [1,2,3])
    self.assertEqual("1\t2\t3", f._to_gfa_field())

  def test_to_gfa_tag(self):
    f = gfapy.FieldArray("i", [1,2,3])
    self.assertEqual("xx:i:1\txx:i:2\txx:i:3", f._to_gfa_tag("xx"))

  def test_vpush(self):
    self.assertRaises(gfapy.FormatError,
      gfapy.FieldArray("i", [1,2,3])._vpush, "x")
    self.assertRaises(gfapy.TypeError,
      gfapy.FieldArray("i", [1,2,3])._vpush, 2.0)
    self.assertRaises(gfapy.InconsistencyError,
      gfapy.FieldArray("i", [1,2,3])._vpush, "z", "Z")
    gfapy.FieldArray("i", [1,2,3])._vpush("z", "i")

