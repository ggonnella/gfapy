import unittest
import gfapy

class TestInternalsTagDatatype(unittest.TestCase):

  def test_datatype_value_independent(self):
    self.assertEqual("Z", gfapy.Field._get_default_gfa_tag_datatype("string"))
    self.assertEqual("i", gfapy.Field._get_default_gfa_tag_datatype(1))
    self.assertEqual("f", gfapy.Field._get_default_gfa_tag_datatype(1.0))
    self.assertEqual("H", gfapy.Field._get_default_gfa_tag_datatype(gfapy.ByteArray([])))
    self.assertEqual("B", gfapy.Field._get_default_gfa_tag_datatype(gfapy.NumericArray([])))
    self.assertEqual("J", gfapy.Field._get_default_gfa_tag_datatype({}))

  def test_datatype_arrays(self):
    self.assertEqual("B", gfapy.Field._get_default_gfa_tag_datatype([1,1]))
    self.assertEqual("B", gfapy.Field._get_default_gfa_tag_datatype([1.0,1.0]))
    self.assertEqual("J", gfapy.Field._get_default_gfa_tag_datatype([1,1.0]))
    self.assertEqual("J", gfapy.Field._get_default_gfa_tag_datatype(["1",1]))
    self.assertEqual("J", gfapy.Field._get_default_gfa_tag_datatype([1.0,"1.0"]))
    self.assertEqual("J", gfapy.Field._get_default_gfa_tag_datatype(["z","z"]))
    self.assertEqual("J", gfapy.Field._get_default_gfa_tag_datatype(
                                        [[1,2,3],[3,4,5]]))
