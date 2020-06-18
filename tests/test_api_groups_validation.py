import gfapy
import unittest

class TestAPIGroupsValidation(unittest.TestCase):

  def test_invalid_path_gfa2(self):
    with self.assertRaises(gfapy.NotFoundError):
      g = gfapy.Gfa.from_file("tests/testdata/invalid_path.gfa2")

  def test_invalid_path_gfa2_vlevel0(self):
    g = gfapy.Gfa.from_file("tests/testdata/invalid_path.gfa2", vlevel = 0)
    with self.assertRaises(gfapy.NotFoundError):
      g.validate()

  def test_valid_path_gfa2(self):
    # nothing raised
    g = gfapy.Gfa.from_file("tests/testdata/valid_path.gfa2")
