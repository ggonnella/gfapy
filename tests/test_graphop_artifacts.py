import gfapy
import unittest

class TestGraphOpArtifacts(unittest.TestCase):

  def test_remove_small_components(self):
    for sfx in ["gfa", "gfa2"]:
      g = gfapy.Gfa.from_file("tests/testdata/two_components.{}".format(sfx))
      self.assertEqual(2, len(g.connected_components()))
      g.remove_small_components(1000)
      self.assertEqual(2, len(g.connected_components()))
      g.remove_small_components(3000)
      self.assertEqual(1, len(g.connected_components()))
      g.remove_small_components(10000)
      self.assertEqual(0, len(g.connected_components()))

  def test_remove_dead_ends(self):
    for sfx in ["gfa", "gfa2"]:
      g = gfapy.Gfa.from_file("tests/testdata/dead_ends.{}".format(sfx))
      self.assertEqual(6, len(g.segments))
      g.remove_dead_ends(100)
      self.assertEqual(6, len(g.segments))
      g.remove_dead_ends(1500)
      self.assertEqual(5, len(g.segments))
      g.remove_dead_ends(1500)
      self.assertEqual(5, len(g.segments))
      g.remove_dead_ends(150000)
      g.remove_dead_ends(150000)
      self.assertEqual(2, len(g.segments))
      g.remove_dead_ends(1500000)
      self.assertEqual(0, len(g.segments))

