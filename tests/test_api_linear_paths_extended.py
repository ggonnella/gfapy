import gfapy
import unittest

class TestgfapyGfaToolsLinearPaths(unittest.TestCase):

  def test_linear_path_merging(self):
    for sfx in ["gfa", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.2."+"{}".format(sfx))
      gfa.merge_linear_path([["0", "R"],["1", "R"],["2", "L"],["3", "R"]],
                            enable_tracking=True)
      gfa.try_get_segment("0_1_2^_3") # nothing raised
      self.assertEqual("ACGACGACGTCGA", gfa.segment("0_1_2^_3").sequence)
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.2."+"{}".format(sfx))
      gfa.merge_linear_path([["0", "R"],["1", "R"],["2", "L"],["3", "R"]],
                            enable_tracking=True)
      gfa.try_get_segment("0_1_2^_3") # nothing raised
      self.assertEqual("ACGACGACGTCGA", gfa.segment("0_1_2^_3").sequence)

  def test_linear_path_merge_all(self):
    for sfx in ["gfa", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.3.{}".format(sfx))
      gfa.merge_linear_paths(enable_tracking=True)
      self.assertIn(gfa.segment_names[0], ["0_1_2^_3","3^_2_1^_0^"])
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.4.{}".format(sfx))
      gfa.merge_linear_paths(enable_tracking=True)
      try:
        self.assertEqual({"0","3","1_2^"}, {x.name for x in gfa.segments})
      except:
        self.assertEqual({"0","3","2_1^"}, {x.name for x in gfa.segments})

