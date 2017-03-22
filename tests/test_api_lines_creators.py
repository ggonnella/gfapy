import gfapy
import unittest

class TestAPILinesCreators(unittest.TestCase):

  def test_add_headers(self):
    gfa = gfapy.Gfa()
    h = "H\tVN:Z:1.0"
    gfa.append(h) # nothing raised
    self.assertEqual([h], [str(x) for x in gfa.headers])

  def test_add_segments(self):
    gfa = gfapy.Gfa()
    s1 = gfapy.Line("S\t1\t*")
    s2 = gfapy.Line("S\t2\t*")
    s2c = gfapy.Line("S\t2\t*")
    gfa.append(s1) # nothing raised
    gfa.append(s2) # nothing raised
    self.assertSetEqual(set([str(s) for s in [s1, s2]]), set([str(s) for s in gfa.segments]))
    self.assertSetEqual(set(["1", "2"]), set(gfa.segment_names))
    self.assertEqual(s1, gfa.segment("1"))
    self.assertEqual(None, gfa.segment("0"))
    gfa.try_get_segment("1") # nothing raised
    with self.assertRaises(gfapy.NotFoundError): gfa.try_get_segment("0")
    with self.assertRaises(gfapy.NotUniqueError): gfa.append(s2c)

  def test_add_links(self):
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    l1 = gfapy.Line("L\t1\t+\t2\t+\t12M")
    l2 = "L\t1\t+\t3\t+\t12M"
    gfa = gfapy.Gfa()
    gfa.append(s1)
    gfa.append(s2)
    gfa.append(l1) # nothing raised
    self.assertEqual([l1], gfa.dovetails)
    self.assertEqual([l1], gfa.segment("1").end_relations("R", ["2", "L"]))
    self.assertEqual([l1], gfa.segment("2").end_relations("L", ["1", "R"]))
    self.assertEqual([], gfa.segment("2").end_relations("R", gfapy.SegmentEnd("1", "L")))
    gfa.append(l2) # nothing raised

  def test_add_containments(self):
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    c1 = gfapy.Line("C\t1\t+\t2\t+\t12\t12M")
    c2 = "C\t1\t+\t3\t+\t12\t12M"
    gfa = gfapy.Gfa()
    gfa.append(s1)
    gfa.append(s2)
    gfa.append(c1) # nothing raised
    self.assertEqual([c1], gfa.containments)
    self.assertEqual([c1],
             gfa.segment("1").relations_to("2", "edges_to_contained"))
    self.assertEqual([],
             gfa.segment("2").relations_to("1", "edges_to_contained"))
    gfa.append(c2) # nothing raised

  def test_add_paths(self):
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    p1 = gfapy.Line("P\t4\t1+,2+\t122M")
    p2 = "P\t1\t1+,2+\t122M"
    p3 = "P\t5\t1+,2+,3+\t122M,120M"
    gfa = gfapy.Gfa()
    gfa.append(s1)
    gfa.append(s2)
    gfa.append(p1) # nothing raised
    self.assertEqual([p1], gfa.paths)
    self.assertEqual(["4"], gfa.path_names)
    self.assertEqual(p1, gfa.line("4"))
    self.assertEqual(None, gfa.line("5"))
    with self.assertRaises(gfapy.NotUniqueError): gfa.append(p2)
    gfa.append(p3) # nothing raised

##  def test_segments_first_order(self):
##    s1 = "S\t1\t*"
##    s2 = "S\t2\t*"
##    l1 = "L\t1\t+\t2\t+\t122M"
##    l2 = "L\t1\t+\t3\t+\t122M"
##    c1 = "C\t1\t+\t2\t+\t12\t12M"
##    c2 = "C\t1\t+\t3\t+\t12\t12M"
##    p1 = "P\t4\t1+,2+\t122M"
##    p2 = "P\t1\t1+,2+\t122M"
##    p3 = "P\t5\t1+,3+\t122M"
##    gfa = gfapy.Gfa()
##    gfa.append(s1)
##    gfa.append(s2)
##    gfa.append(l1) # nothing raised
##    with self.assertRaises(gfapy.NotFoundError): gfa.append(l2)
##    gfa.append(c1) # nothing raised
##    with self.assertRaises(gfapy.NotFoundError): gfa.append(c2)
##    gfa.append(p1) # nothing raised
##    with self.assertRaises(gfapy.NotUniqueError): gfa.append(p2)
##    with self.assertRaises(gfapy.NotFoundError): gfa.append(p3)

  def test_header_add(self):
    gfa = gfapy.Gfa()
    gfa.append("H\tVN:Z:1.0")
    gfa.append("H\taa:i:12\tab:Z:test1")
    gfa.append("H\tac:Z:test2")
    gfa.header.add("aa", 15)
    self.assertSetEqual(
      set([
        "H\tVN:Z:1.0",
        "H\taa:i:12",
        "H\taa:i:15",
        "H\tab:Z:test1",
        "H\tac:Z:test2",
      ]),
      set([str(x) for x in gfa.headers]))
    gfa.header.add("aa", 16)
    self.assertSetEqual(
      set([
        "H\tVN:Z:1.0",
        "H\taa:i:12",
        "H\taa:i:15",
        "H\taa:i:16",
        "H\tab:Z:test1",
        "H\tac:Z:test2",
      ]),
      set([str(x) for x in gfa.headers]))
    gfa.header.delete("aa")
    gfa.header.aa = 26
    self.assertEqual(
      set([
        "H\tVN:Z:1.0",
        "H\taa:i:26",
        "H\tab:Z:test1",
        "H\tac:Z:test2",
      ]),
      set([str(x) for x in gfa.headers]))

