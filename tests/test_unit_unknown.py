import unittest
import gfapy

class TestUnitUnknown(unittest.TestCase):

  u = gfapy.line.Unknown([None, "a"])

  def test_new(self):
    assert(isinstance(TestUnitUnknown.u, gfapy.line.Unknown))

  def test_str(self):
    self.assertEqual("?record_type?\ta\tco:Z:line_created_by_gfapy",
        str(TestUnitUnknown.u))

  def test_tags(self):
    with self.assertRaises(AttributeError):
      TestUnitUnknown.u.xx
    self.assertEqual(None, TestUnitUnknown.u.get("xx"))
    with self.assertRaises(gfapy.RuntimeError):
      TestUnitUnknown.u.xx = 1
    self.assertRaises(gfapy.RuntimeError,
        TestUnitUnknown.u.set,"xx",1)

  def test_virtual(self):
    assert(TestUnitUnknown.u.virtual)
