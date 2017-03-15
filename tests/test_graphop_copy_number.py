import gfapy
import unittest

class TestGraphopCopyNumber(unittest.TestCase):

  def test_delete_low_coverage_segments(self):
    for sfx in ["gfa", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/copynum.1.{}".format(sfx))
      self.assertEqual({"0","1","2"}, set(gfa.segment_names))
      gfa.delete_low_coverage_segments(10)
      self.assertEqual({"1","2"}, set(gfa.segment_names))
      gfa.delete_low_coverage_segments(100)
      self.assertEqual({"2"}, set(gfa.segment_names))
      gfa.delete_low_coverage_segments(1000)
      self.assertEqual(set(), set(gfa.segment_names))

  def test_compute_copy_numbers(self):
    for sfx in ["gfa", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/copynum.2.{}".format(sfx))
      gfa.compute_copy_numbers(9) # nothing raised
      self.assertEqual(0, gfa.try_get_segment("0").cn)
      self.assertEqual(1, gfa.try_get_segment("1").cn)
      self.assertEqual(2, gfa.try_get_segment("2").cn)
      self.assertEqual(3, gfa.try_get_segment("3").cn)

  def test_apply_copy_number(self):
    for sfx in ["gfa", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/copynum.2.{}".format(sfx))
      self.assertEqual({"0","1","2","3"}, set(gfa.segment_names))
      gfa.compute_copy_numbers(9)
      gfa.apply_copy_numbers()
      self.assertEqual({"1","2","3","2*2","3*2","3*3"}, set(gfa.segment_names))
      gfa.compute_copy_numbers(9)
      assert(all(x.cn == 1 for x in gfa.segments))

