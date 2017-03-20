import gfapy
import unittest

class TestAPIRenameLines(unittest.TestCase):

  def test_rename(self):
    gfa = gfapy.Gfa(["S\t0\t*", "S\t1\t*", "S\t2\t*",
      "L\t0\t+\t2\t-\t12M", "C\t1\t+\t0\t+\t12\t12M", "P\t4\t2+,0-\t12M"])
    gfa.segment("0").name = "X"
    with self.assertRaises(gfapy.NotFoundError): gfa.try_get_segment("0")
    self.assertEqual(set(["X", "1", "2"]), set(gfa.segment_names))
    self.assertEqual("L\tX\t+\t2\t-\t12M", str(gfa.dovetails[0]))
    self.assertEqual("C\t1\t+\tX\t+\t12\t12M", str(gfa.containments[0]))
    self.assertEqual("P\t4\t2+,X-\t12M", str(gfa.paths[0]))
    with self.assertRaises(gfapy.NotFoundError): gfa.try_get_segment("0").dovetails_of_end("R")
    self.assertEqual("L\tX\t+\t2\t-\t12M", str(gfa.segment("X").dovetails_of_end("R")[0]))
    self.assertEqual("C\t1\t+\tX\t+\t12\t12M",
                 str(gfa.try_get_segment("1").edges_to_contained[0]))
    with self.assertRaises(gfapy.NotFoundError): gfa.try_get_segment("0").containers
    self.assertEqual("C\t1\t+\tX\t+\t12\t12M",
                 str(gfa.try_get_segment("X").edges_to_containers[0]))
    self.assertEqual("P\t4\t2+,X-\t12M", str(gfa.try_get_segment("X").paths[0]))

