import gfapy
import unittest

class TestAPIReferencesVirtual(unittest.TestCase):

  def test_edges_gaps_create_virtual_segments(self):
    data = [
      ["gfa1", {"lines":["L\ta\t+\tb\t-\t*", "C\ta\t-\tb\t+\t100\t*"],
               "m1":"oriented_from", "m2":"oriented_to",
               "sA":"S\ta\t*", "sB":"S\tb\t*",
               "collection":"edges"}],
      ["gfa2", {"lines":["E\t*\ta+\tb-\t0\t100\t900\t1000$\t*"],
               "m1":"sid1", "m2":"sid2",
               "sA":"S\ta\t1000\t*", "sB":"S\tb\t1000\t*",
               "collection":"edges"}],
      ["gfa2", {"lines":["G\t*\ta+\tb-\t1000\t100"],
               "m1":"sid1", "m2":"sid2",
               "sA":"S\ta\t1000\t*", "sB":"S\tb\t1000\t*",
               "collection":"gaps"}]
    ]
    for v,values in data:
      for linestr in values["lines"]:
        g = gfapy.Gfa(version=v)
        line = gfapy.Line.from_string(linestr)
        g.append(line)
        self.assertEqual(set(["a", "b"]), set([x.name for x in g.segments]))
        for s in g.segments: assert(s.virtual)
        sA = gfapy.Line.from_string(values["sA"])
        g.append(sA)
        self.assertEqual(set(["a", "b"]), set([x.name for x in g.segments]))
        assert(not g.segment("a").virtual)
        assert(g.segment("b").virtual)
        self.assertEqual(sA, getattr(line,values["m1"]).line)
        self.assertEqual(sA, g.segment("a"))
        self.assertEqual([line], getattr(sA,values["collection"]))
        sB = gfapy.Line.from_string(values["sB"])
        g.append(sB)
        self.assertEqual(set(["a", "b"]), set([x.name for x in g.segments]))
        assert(not g.segment("b").virtual)
        self.assertEqual(sB, getattr(line,values["m2"]).line)
        self.assertEqual(sB, g.segment("b"))
        self.assertEqual([line], getattr(sB,values["collection"]))

  def test_fragments_create_virtual_segments(self):
    g = gfapy.Gfa(version="gfa2")
    fr = gfapy.Line.from_string("F\ta\tread10-\t0\t10\t990\t1000$\t*")
    g.append(fr)
    self.assertEqual(["a"], [x.name for x in g.segments])
    assert(g.segment("a").virtual)
    sA = gfapy.Line.from_string("S\ta\t1000\t*")
    g.append(sA)
    self.assertEqual(["a"], [x.name for x in g.segments])
    assert(not g.segment("a").virtual)
    self.assertEqual(sA, fr.sid)
    self.assertEqual(sA, g.segment("a"))
    self.assertEqual([fr], sA.fragments)

  def test_paths_create_virtual_links(self):
    g = gfapy.Gfa(version="gfa1")
    path = gfapy.Line.from_string("P\tp1\tb+,ccc-,e+\t10M1I2M,15M")
    g.append(path)
    for i in path.segment_names: assert(i.line.virtual)
    self.assertEqual(set(["b", "ccc", "e"]), set([x.name for x in g.segments]))
    sB = gfapy.Line.from_string("S\tb\t*")
    g.append(sB)
    assert(not path.segment_names[0].line.virtual)
    self.assertEqual(sB, path.segment_names[0].line)
    self.assertEqual([path], sB.paths)
    for i in path.links: assert(i.line.virtual)
    l = gfapy.Line.from_string("L\tccc\t+\tb\t-\t2M1D10M")
    g.append(l)
    assert(not path.links[0].line.virtual)
    self.assertEqual(l, path.links[0].line)
    self.assertEqual([path], l.paths)
    l = gfapy.Line.from_string("L\tccc\t-\te\t+\t15M")
    g.append(l)
    assert(not path.links[1].line.virtual)
    self.assertEqual(l, path.links[1].line)
    self.assertEqual([path], l.paths)

  def test_ordered_groups_create_virtual_unknown_records(self):
    g = gfapy.Gfa(version="gfa2")
    path = gfapy.Line.from_string("O\tp1\tchildpath- b+ c- edge-")
    g.append(path)
    for i in path.items:
      assert(i.line.virtual)
      self.assertEqual(None, i.line.record_type)
    childpath = gfapy.Line.from_string("O\tchildpath\tf+ a+")
    g.append(childpath)
    assert(not path.items[0].line.virtual)
    self.assertEqual(childpath, path.items[0].line)
    self.assertEqual([path], childpath.paths)
    sB = gfapy.Line.from_string("S\tb\t1000\t*")
    g.append(sB)
    assert(not path.items[1].line.virtual)
    self.assertEqual(sB, path.items[1].line)
    self.assertEqual([path], sB.paths)
    edge = gfapy.Line.from_string("E\tedge\te-\tc+\t0\t100\t900\t1000$\t*")
    g.append(edge)
    assert(not path.items[-1].line.virtual)
    self.assertEqual(edge, path.items[-1].line)
    self.assertEqual([path], edge.paths)

  def test_unordered_groups_create_virtual_unknown_records(self):
    g = gfapy.Gfa(version="gfa2")
    set = gfapy.Line.from_string("U\tset\tchildpath b childset edge")
    g.append(set)
    for i in set.items:
      assert(i.virtual)
      self.assertEqual(None, i.record_type)
    childpath = gfapy.Line.from_string("O\tchildpath\tf+ a+")
    g.append(childpath)
    assert(not set.items[0].virtual)
    self.assertEqual(childpath, set.items[0])
    self.assertEqual([set], childpath.sets)
    sB = gfapy.Line.from_string("S\tb\t1000\t*")
    g.append(sB)
    assert(not set.items[1].virtual)
    self.assertEqual(sB, set.items[1])
    self.assertEqual([set], sB.sets)
    childset = gfapy.Line.from_string("U\tchildset\tg edge2")
    g.append(childset)
    assert(not set.items[2].virtual)
    self.assertEqual(childset, set.items[2])
    self.assertEqual([set], childset.sets)
    edge = gfapy.Line.from_string("E\tedge\te-\tc+\t0\t100\t900\t1000$\t*")
    g.append(edge)
    assert(not set.items[3].virtual)
    self.assertEqual(edge, set.items[3])
    self.assertEqual([set], edge.sets)

