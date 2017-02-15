import gfapy
import unittest

class TestAPILinesDestructors(unittest.TestCase):

  def test_delete_links(self):
    gfa = gfapy.Gfa()
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    for line in (s + [l,c]): gfa.append(line)
    self.assertEqual([l], [str(x) for x in gfa.dovetails])
    self.assertEqual([l], [str(x) for x in \
        gfa.segment("1").end_relations("R", ["2", "L"])])
    for x in gfa.segment("1").oriented_relations("+", \
               gfapy.OrientedLine("2", "+")):
      x.disconnect()
    self.assertEqual([], gfa.dovetails)
    self.assertEqual([], gfa.segment("1").end_relations("R", ["2", "L"]))
    self.assertEqual([c], [str(x) for x in gfa.containments])
    self.assertEqual(c,
                 str(gfa.segment("1").relations_to(gfa.segment("0"),
                                    "edges_to_contained")[0]))
    gfa.append(l)
    self.assertNotEqual([], gfa.dovetails)
    for x in gfa.segment("1").oriented_relations("+", \
               gfapy.OrientedLine("2", "+")):
      x.disconnect()
    self.assertEqual([], gfa.dovetails)

  def test_delete_containments(self):
    gfa = gfapy.Gfa()
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    for line in (s + [l,c]): gfa.append(line)
    for x in gfa.segment("1").relations_to(gfa.segment("0"), "edges_to_contained"):
      x.disconnect()
    self.assertEqual([], gfa.containments)
    self.assertEqual(0, len(gfa.segment("1").relations_to("0",
                                                     "edges_to_contained")))
    gfa.append(c)
    self.assertNotEqual([], gfa.containments)
    self.assertEqual(c, str(gfa.segment("1").relations_to("0",
                                                   "edges_to_contained")[0]))
    for x in gfa.segment("1").relations_to(gfa.segment("0"), "edges_to_contained"):
      x.disconnect()
    self.assertEqual([], gfa.containments)

  def test_delete_segment(self):
    gfa = gfapy.Gfa()
    gfa.append("H\tVN:Z:1.0")
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    p = "P\t4\t2+,0-\t12M"
    for line in (s + [l,c,p]): gfa.append(line)
    self.assertEqual(set(s), set([str(x) for x in gfa.segments]))
    self.assertEqual(set(["0", "1", "2"]), set(gfa.segment_names))
    self.assertEqual([l], [str(x) for x in gfa.dovetails if not x.virtual])
    self.assertEqual([c], [str(x) for x in gfa.containments])
    self.assertEqual([p], [str(x) for x in gfa.paths])
    self.assertEqual(["4"], gfa.path_names)
    gfa.segment("0").disconnect()
    self.assertEqual(set([s[1],s[2]]), set([str(x) for x in gfa.segments]))
    self.assertEqual(set(["1", "2"]), set(gfa.segment_names))
    self.assertEqual([l], [str(x) for x in gfa.dovetails if not x.virtual])
    self.assertEqual([], [str(x) for x in gfa.containments])
    self.assertEqual([], [str(x) for x in gfa.paths])
    self.assertEqual([], gfa.path_names)
    gfa.segment("1").disconnect()
    self.assertEqual([s[2]], [str(x) for x in gfa.segments])
    self.assertEqual([], gfa.dovetails)
    gfa.rm("2")
    self.assertEqual([], gfa.segments)

