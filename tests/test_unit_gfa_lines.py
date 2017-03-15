import unittest
import gfapy

class TestUnitGfaLines(unittest.TestCase):

  def test_register_line_merge(self):
    g = gfapy.Gfa(version="gfa1")
    l = gfapy.line.Header({"xx": 1}, version="gfa1")
    l._gfa = g
    g._register_line(l)
    self.assertEqual(1, g.header.xx)
    self.assertRaises(gfapy.AssertionError, g._unregister_line, l)

  def test_register_line_name_present(self):
    g = gfapy.Gfa(version="gfa1")
    l = gfapy.line.segment.GFA1({"name": "sx"}, version="gfa1")
    l._gfa = g
    g._register_line(l)
    self.assertEqual([l], g.segments)
    self.assertEqual(l, g.line("sx"))
    self.assertEqual(["sx"], g.segment_names)
    g._unregister_line(l)
    self.assertEqual([], g.segments)
    self.assertEqual(None, g.line("sx"))
    self.assertEqual([], g.segment_names)

  def test_register_line_name_absent(self):
    g = gfapy.Gfa(version="gfa2")
    l = gfapy.line.edge.GFA2({"eid": gfapy.Placeholder()},
                             version="gfa2")
    l._gfa = g
    g._register_line(l)
    self.assertEqual([l], g.edges)
    self.assertEqual([], g.edge_names)
    g._unregister_line(l)
    self.assertEqual([], g.edges)

  def test_register_line_external(self):
    g = gfapy.Gfa(version="gfa2")
    l = gfapy.line.Fragment({"external": gfapy.OrientedLine("x","+")},
                                  version="gfa2")
    l._gfa = g
    g._register_line(l)
    self.assertEqual([l], g.fragments)
    self.assertEqual([l], g.fragments_for_external("x"))
    self.assertEqual(["x"], g.external_names)
    g._unregister_line(l)
    self.assertEqual([], g.fragments)
    self.assertEqual([], g.fragments_for_external("x"))
    self.assertEqual([], g.external_names)

  def test_register_line_unnamed(self):
    g = gfapy.Gfa(version="gfa1")
    l = gfapy.line.edge.Link({}, version="gfa1")
    l._gfa = g
    g._register_line(l)
    self.assertEqual([l], g.dovetails)
    g._unregister_line(l)
    self.assertEqual([], g.dovetails)


