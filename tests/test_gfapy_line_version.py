import gfapy
import unittest

class TestLineVersion(unittest.TestCase):

  def test_header(self):
    self.assertEqual("generic", gfapy.Line("H\tVN:Z:1.0").version)
    self.assertEqual("gfa1", gfapy.Line("H\tVN:Z:1.0", version = "gfa1").version)
    self.assertEqual("gfa2", gfapy.Line("H\tVN:Z:1.0", version = "gfa2").version)

  def test_comment(self):
    self.assertEqual("generic", gfapy.Line("# VN:Z:1.0").version)
    self.assertEqual("gfa1", gfapy.Line("# VN:Z:1.0", version = "gfa1").version)
    self.assertEqual("gfa2", gfapy.Line("# VN:Z:1.0", version = "gfa2").version)

  def test_segment(self):
    self.assertEqual("gfa1", gfapy.Line("S\tA\tNNNN").version)
    self.assertEqual("gfa2", gfapy.Line("S\tA\t1\tNNNN").version)
    self.assertEqual("gfa1", gfapy.Line("S\tA\tNNNN", version = "gfa1").version)
    self.assertEqual("gfa2", gfapy.Line("S\tA\t1\tNNNN", version = "gfa2").version)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("S\tA\t1\tNNNN", version = "gfa1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("S\tA\tNNNN", version = "gfa2")

  def test_link(self):
    self.assertEqual("gfa1", gfapy.Line("L\tA\t+\tB\t-\t*").version)
    self.assertEqual("gfa1",
           gfapy.Line("L\tA\t+\tB\t-\t*", version = "gfa1").version)
    with self.assertRaises(gfapy.VersionError):
      gfapy.Line("L\tA\t+\tB\t-\t*", version = "gfa2")
    with self.assertRaises(gfapy.VersionError):
      gfapy.line.edge.Link(["A","+","B","-","*"], version = "gfa2")

  def test_containment(self):
    self.assertEqual("gfa1", gfapy.Line("C\tA\t+\tB\t-\t10\t*").version)
    self.assertEqual("gfa1",
       gfapy.Line("C\tA\t+\tB\t-\t10\t*", version = "gfa1").version)
    with self.assertRaises(gfapy.VersionError):
      gfapy.Line("C\tA\t+\tB\t-\t10\t*", version = "gfa2")
    with self.assertRaises(gfapy.VersionError):
      gfapy.line.edge.Containment(["A","+","B","-","10","*"], version = "gfa2")

  def test_custom_record(self):
    self.assertEqual("gfa2", gfapy.Line("X\tVN:Z:1.0").version)
    self.assertEqual("gfa2", gfapy.Line("X\tVN:Z:1.0", version = "gfa2").version)
    with self.assertRaises(gfapy.VersionError):
      gfapy.Line("X\tVN:Z:1.0", version = "gfa1")
    with self.assertRaises(gfapy.VersionError):
      gfapy.line.CustomRecord(["X","VN:Z:1.0"], version = "gfa1")
