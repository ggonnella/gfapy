import gfapy
import unittest

class TestAPIReferencesGroups(unittest.TestCase):

  def test_paths_references(self):
    g = gfapy.Gfa()
    s = {}; l = {}
    for name in ["a", "b", "c", "d", "e", "f"]:
      s[name] = gfapy.Line("S\t{}\t*".format(name))
      g.append(s[name])
    path = gfapy.Line("P\tp1\tf+,a+,b+,c-,e+\t*")
    self.assertEqual([gfapy.OrientedLine("f","+"), gfapy.OrientedLine("a","+"),
                      gfapy.OrientedLine("b","+"), gfapy.OrientedLine("c","-"),
                      gfapy.OrientedLine("e","+")], path.segment_names)
    self.assertEqual([], path.links)
    # connection
    g.append(path)
    # add links
    for name in ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-"]:
      l[name] = gfapy.Line("\t".join((list("L{}*".format(name)))))
      g.append(l[name])
    # segment_names
    self.assertEqual([gfapy.OrientedLine(s["f"],"+"),
                      gfapy.OrientedLine(s["a"],"+"),
                      gfapy.OrientedLine(s["b"],"+"),
                      gfapy.OrientedLine(s["c"],"-"),
                      gfapy.OrientedLine(s["e"],"+")], path.segment_names)
    # links
    self.assertEqual([gfapy.OrientedLine(l["a-f-"],"-"),
                      gfapy.OrientedLine(l["a+b+"],"+"),
                      gfapy.OrientedLine(l["b+c-"],"+"),
                      gfapy.OrientedLine(l["e-c+"],"-")],
                      path.links)
    # path disconnection
    path.disconnect()
    self.assertEqual([gfapy.OrientedLine("f","+"),
                      gfapy.OrientedLine("a","+"),
                      gfapy.OrientedLine("b","+"),
                      gfapy.OrientedLine("c","-"),
                      gfapy.OrientedLine("e","+")], path.segment_names)
    self.assertEqual([], path.links)
    g.append(path)
    # links disconnection cascades on paths:
    assert(path.is_connected())
    l["a-f-"].disconnect()
    assert(not path.is_connected())
    self.assertEqual([gfapy.OrientedLine("f","+"),
                      gfapy.OrientedLine("a","+"),
                      gfapy.OrientedLine("b","+"),
                      gfapy.OrientedLine("c","-"),
                      gfapy.OrientedLine("e","+")], path.segment_names)
    g.append(path)
    g.append(l["a-f-"])
    # segment disconnection cascades on links and then paths:
    assert(path.is_connected())
    s["a"].disconnect()
    assert(not path.is_connected())
    self.assertEqual([gfapy.OrientedLine("f","+"),
                      gfapy.OrientedLine("a","+"),
                      gfapy.OrientedLine("b","+"),
                      gfapy.OrientedLine("c","-"),
                      gfapy.OrientedLine("e","+")], path.segment_names)
    self.assertEqual([], path.links)

  def test_paths_backreferences(self):
    g = gfapy.Gfa()
    s = {}; l = {}
    for name in ["a", "b", "c", "d", "e", "f"]:
      s[name] = gfapy.Line("S\t{}\t*".format(name))
      g.append(s[name])
    path = gfapy.Line("P\tp1\tf+,a+,b+,c-,e+\t*")
    g.append(path)
    for sname in ["a", "b", "c", "e", "f"]:
      self.assertEqual([path], s[sname].paths)
    self.assertEqual([], s["d"].paths)
    for name in ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-"]:
      l[name] = gfapy.Line("\t".join(list("L{}*".format(name))))
      g.append(l[name])
    for lname in ["a+b+", "b+c-", "e-c+", "a-f-"]:
      self.assertEqual([path], l[lname].paths)
    self.assertEqual([], l["c-d+"].paths)
    # disconnection effects
    path.disconnect()
    for lname in ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-"]:
      self.assertEqual([], l[lname].paths)
    for sname in ["a", "b", "c", "d", "e", "f"]:
      self.assertEqual([], s[sname].paths)
    # reconnection
    path.connect(g)
    for sname in ["a", "b", "c", "e", "f"]:
      self.assertEqual([path], s[sname].paths)
    self.assertEqual([], s["d"].paths)
    for lname in ["a+b+", "b+c-", "e-c+", "a-f-"]:
      self.assertEqual([path], l[lname].paths)
    self.assertEqual([], l["c-d+"].paths)

  def test_gfa2_paths_references(self):
    g = gfapy.Gfa()
    s = {}
    for name in ["a", "b", "c", "d", "e", "f"]:
      s[name] = gfapy.Line("S\t{}\t1000\t*".format(name))
      g.append(s[name])
    path1_part1 = gfapy.Line("O\tp1\tp2- b+")
    path1_part2 = gfapy.Line("O\tp1\tc- e-c+-")
    path1 = path1_part2
    path2 = gfapy.Line("O\tp2\tf+ a+")
    self.assertEqual([gfapy.OrientedLine("p2","-"),
                      gfapy.OrientedLine("b","+")], path1_part1.items)
    self.assertEqual([gfapy.OrientedLine("c","-"),
                      gfapy.OrientedLine("e-c+","-")], path1_part2.items)
    self.assertEqual([gfapy.OrientedLine("f","+"),
                      gfapy.OrientedLine("a","+")], path2.items)
    with self.assertRaises(gfapy.RuntimeError): path1.captured_path
    with self.assertRaises(gfapy.RuntimeError): path2.captured_path
    # connection
    g.append(path1_part1)
    g.append(path1_part2)
    g.append(path2)
    # edges
    e = {}
    for name in ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-", "f-b+"]:
      coord1 = "900\t1000$" if (name[1] == "+") else "0\t100"
      coord2 = "0\t100" if (name[3] == "+")  else "900\t1000$"
      e[name] = gfapy.Line("E\t{}\t{}\t{}\t{}\t{}\t100M".format(name,name[0:2],name[2:4],coord1,coord2))
      g.append(e[name])
    # items
    self.assertEqual([gfapy.OrientedLine(path2,"-"),
                      gfapy.OrientedLine(s["b"],"+"),
                      gfapy.OrientedLine(s["c"],"-"),
                      gfapy.OrientedLine(e["e-c+"],"-")],
                      path1.items)
    self.assertEqual([gfapy.OrientedLine(s["f"],"+"),
                      gfapy.OrientedLine(s["a"],"+")],
                      path2.items)
    # induced set
    self.assertEqual([gfapy.OrientedLine(s["f"],"+"),
                      gfapy.OrientedLine(e["a-f-"],"-"),
                      gfapy.OrientedLine(s["a"],"+")],
                      path2.captured_path)
    self.assertEqual([gfapy.OrientedLine(s["a"],"-"),
                      gfapy.OrientedLine(e["a-f-"],"+"),
                      gfapy.OrientedLine(s["f"],"-"),
                      gfapy.OrientedLine(e["f-b+"],"+"),
                      gfapy.OrientedLine(s["b"],"+"),
                      gfapy.OrientedLine(e["b+c-"],"+"),
                      gfapy.OrientedLine(s["c"],"-"),
                      gfapy.OrientedLine(e["e-c+"],"-"),
                      gfapy.OrientedLine(s["e"],"+")],
                      path1.captured_path)
    # backreferences
    for line in [path2, s["b"], s["c"], e["e-c+"]]:
      self.assertEqual([path1], line.paths)
    for line in [s["f"], s["a"]]:
      self.assertEqual([path2], line.paths)
    # group disconnection
    path1.disconnect()
    self.assertEqual([gfapy.OrientedLine("p2","-"), gfapy.OrientedLine("b","+"), gfapy.OrientedLine("c","-"), gfapy.OrientedLine("e-c+","-")],
                 path1.items)
    with self.assertRaises(gfapy.RuntimeError):
      path1.captured_path
    self.assertEqual([gfapy.OrientedLine(s["f"],"+"), gfapy.OrientedLine(s["a"],"+")], path2.items)
    for line in [path2, s["b"], s["c"], e["e-c+"]]:
      self.assertEqual([], line.paths)
    # group reconnection
    g.append(path1)
    self.assertEqual([gfapy.OrientedLine(path2,"-"), gfapy.OrientedLine(s["b"],"+"), gfapy.OrientedLine(s["c"],"-"), gfapy.OrientedLine(e["e-c+"],"-")],
                 path1.items)
    self.assertEqual([gfapy.OrientedLine(s["f"],"+"), gfapy.OrientedLine(s["a"],"+")], path2.items)
    for line in [path2, s["b"], s["c"], e["e-c+"]]:
      self.assertEqual([path1], line.paths)
    # item disconnection cascades on group
    assert(path1.is_connected())
    assert(path2.is_connected())
    e["e-c+"].disconnect()
    assert(not path1.is_connected())
    assert(path2.is_connected())
    g.append(e["e-c+"])
    g.append(path1)
    # two-level disconnection cascade
    assert(path1.is_connected())
    assert(path2.is_connected())
    s["f"].disconnect()
    assert(not path2.is_connected())
    assert(not path1.is_connected())

  def test_sets_references(self):
    g = gfapy.Gfa()
    s = {}
    set1 = gfapy.Line("U\tset1\tb set2 c e-c+")
    set2 = gfapy.Line("U\tset2\tg c-d+ path1")
    path1 = gfapy.Line("O\tpath1\tf+ a+")
    self.assertEqual(["b", "set2", "c", "e-c+"], set1.items)
    self.assertEqual(["g", "c-d+", "path1"], set2.items)
    # induced set of non-connected cannot be computed
    with self.assertRaises(gfapy.RuntimeError): set1.induced_set
    with self.assertRaises(gfapy.RuntimeError): set2.induced_set
    # connection
    g.append(set1)
    g.append(set2)
    # induced set cannot be computed, as long as not all references are solved
    with self.assertRaises(gfapy.RuntimeError): set1.induced_set
    # connect items
    g.append(path1)
    for name in ["a", "b", "c", "d", "e", "f", "g"]:
      s[name] = gfapy.Line("S\t"+"{}".format(name)+"\t1000\t*")
      g.append(s[name])
    e = {}
    for name in ["a+b+", "b+c-", "c-d+", "e-c+", "a-f-"]:
      coord1 = "900\t1000$" if (name[1] == "+") else "0\t100"
      coord2 = "0\t100" if (name[3] == "+")  else "900\t1000$"
      e[name] = gfapy.Line("E\t{}\t{}\t{}\t{}\t{}\t100M".format(name,name[0:2],name[2:4],coord1,coord2))
      g.append(e[name])
    # items
    self.assertEqual([s["b"], set2, s["c"], e["e-c+"]], set1.items)
    self.assertEqual([s["g"], e["c-d+"], path1], set2.items)
    # induced set
    self.assertEqual([gfapy.OrientedLine(s["f"],"+"), gfapy.OrientedLine(s["a"],"+")],
                 path1.captured_segments)
    self.assertEqual(set([x.name for x in [s["g"], s["c"], s["d"], s["f"], s["a"]]]),
                     set([x.name for x in set2.induced_segments_set]))
    self.assertEqual(set([x.name for x in [s["b"], s["g"], s["c"], s["d"], s["f"], s["a"], s["e"]]]),
                     set([x.name for x in set1.induced_segments_set]))
    self.assertEqual(set([x.name for x in [e["c-d+"], e["a-f-"]]]),
                     set([x.name for x in set2.induced_edges_set]))
    self.assertEqual([e["a+b+"],e["b+c-"],e["c-d+"],e["e-c+"],e["a-f-"]],
                 set1.induced_edges_set)
    self.assertEqual(set([x.name for x in set1.induced_segments_set + set1.induced_edges_set]),
                     set([x.name for x in set1.induced_set]))
    # backreferences
    for line in [s["b"], set2, s["c"], e["e-c+"]]: 
      self.assertEqual([set1], line.sets)
    for line in [s["g"], e["c-d+"], path1]: 
      self.assertEqual([set2], line.sets)
    # group disconnection
    set1.disconnect()
    self.assertEqual(["b", "set2", "c", "e-c+"], set1.items)
    for line in [s["b"], set2, s["c"], e["e-c+"]]: 
      self.assertEqual([], line.sets)
    # group reconnection
    g.append(set1)
    self.assertEqual([s["b"], set2, s["c"], e["e-c+"]], set1.items)
    for line in [s["b"], set2, s["c"], e["e-c+"]]: 
      self.assertEqual([set1], line.sets)
    # item disconnection cascades on group
    assert(set1.is_connected())
    e["e-c+"].disconnect()
    assert(not set1.is_connected())
    g.append(e["e-c+"])
    g.append(set1)
    # multilevel disconnection cascade
    assert(path1.is_connected())
    assert(set2.is_connected())
    assert(set1.is_connected())
    s["f"].disconnect()
    assert(not path1.is_connected())
    assert(not set2.is_connected())
    assert(not set1.is_connected())

