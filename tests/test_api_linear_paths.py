import gfapy
import unittest

class TestAPILinearPaths(unittest.TestCase):

  def test_linear_path_merging(self):
    for sfx in ["gfa", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.1."+"{}".format(sfx))
      with self.assertRaises(gfapy.ValueError):
        gfa.merge_linear_path([["0", "R"],["1", "R"],["2", "L"],["3", "R"]])
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.2."+"{}".format(sfx))
      gfa.merge_linear_path([["0", "R"],["1", "R"],["2", "L"],["3", "R"]])
      with self.assertRaises(gfapy.NotFoundError): gfa.try_get_segment("0")
      with self.assertRaises(gfapy.NotFoundError): gfa.try_get_segment("1")
      with self.assertRaises(gfapy.NotFoundError): gfa.try_get_segment("2")
      with self.assertRaises(gfapy.NotFoundError): gfa.try_get_segment("3")
      gfa.try_get_segment("0_1_2_3") # nothing raised
      self.assertEqual([], gfa.dovetails)
      self.assertEqual("ACGACGACGTCGA", gfa.segment("0_1_2_3").sequence)

  def test_linear_path_merge_all(self):
    for sfx in ["gfa", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.3."+"{}".format(sfx))
      gfa.merge_linear_paths()
      gfa.merge_linear_paths() # nothing raised
      self.assertEqual(len(gfa.segment_names), 1)
      self.assertIn(gfa.segment_names[0], ["0_1_2_3","3_2_1_0"])
      self.assertEqual(len(gfa.segments), 1)
      self.assertEqual(len(gfa.dovetails), 0)
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.4."+"{}".format(sfx))
      gfa.merge_linear_paths() # nothing raised
      self.assertEqual(3, len(gfa.segments))
      for x in gfa.segments:
        self.assertIn(x.name, {"0","3","1_2","2_1"})
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.5."+"{}".format(sfx))
      gfa.merge_linear_paths() # nothing raised
      self.assertEqual(3, len(gfa.segments))
      self.assertEqual({"0", "1", "2_3"}, {x.name for x in gfa.segments})

  def test_linear_path_merge_example1(self):
    for sfx in ["gfa", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/example1."+"{}".format(sfx))
      lps = set()
      for i, lp in enumerate(gfa.linear_paths()):
        if int(lp[0].name) > int(lp[-1].name):
          lp.reverse()
        lps.add(" ".join([s.name for s in lp]))
      self.assertEqual({"1 19 18", "11 9 12", "22 16 20 21 23"}, lps)

  def test_linear_path_merge_6(self):
    gfa = gfapy.Gfa.from_file("tests/testdata/linear_merging.6.gfa")
    expected = gfapy.Gfa.from_file("tests/testdata/linear_merging.6.merged.gfa")
    gfa.merge_linear_paths()
    self.assertEqual(set(gfa.segment_names), set(expected.segment_names))
    dovetails_gfa = [str(l) for l in gfa.dovetails].sort()
    dovetails_expected = [str(l) for l in expected.dovetails].sort()
    self.assertEqual(dovetails_gfa, dovetails_expected)

  def test_linear_path_blunt_ends(self):
    for sfx in ["gfa1", "gfa2"]:
      gfa = gfapy.Gfa.from_file("tests/testdata/linear_blunt."+"{}".format(sfx))
      gfa.merge_linear_paths()
      self.assertEqual(1, len(gfa.segments))
      self.assertEqual("s1_s2_s3_s4", gfa.segments[0].name)
      self.assertEqual("CTGAAACGTGGCTCACA", gfa.segments[0].sequence)
