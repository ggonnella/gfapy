import gfapy
import unittest

class TestAPIReferencesEdgesGFA1(unittest.TestCase):

  def test_links_references(self):
    g = gfapy.Gfa()
    lab = gfapy.Line("L\ta\t+\tb\t+\t*")
    self.assertEqual("a", lab.from_segment)
    self.assertEqual("b", lab.to_segment)
    g.append(lab)
    sa = gfapy.Line("S\ta\t*")
    g.append(sa)
    sb = gfapy.Line("S\tb\t*")
    g.append(sb)
    self.assertEqual(sa, lab.from_segment)
    self.assertEqual(sb, lab.to_segment)
    lab.disconnect()
    self.assertEqual("a", lab.from_segment)
    self.assertEqual("b", lab.to_segment)
    # disconnection of segment cascades on links
    g.append(lab)
    assert(lab.is_connected())
    self.assertEqual(sa, lab.from_segment)
    sa.disconnect()
    assert(not lab.is_connected())
    self.assertEqual("a", lab.from_segment)

  def test_links_backreferences(self):
    g = gfapy.Gfa()
    sa = gfapy.Line("S\ta\t*")
    g.append(sa)
    # links
    s = {}; l = {}
    for name in ["b", "c", "d", "e", "f", "g", "h", "i"]:
      s[name] = gfapy.Line("S\t{}\t*".format(name))
      g.append(s[name])
    for name in \
         ["a+b+", "a+c-", "a-d+", "a-e-", "f+a+", "g+a-", "h-a+", "i-a-"]:
      l[name] = gfapy.Line("\t".join(list("L"+name+"*")))
      g.append(l[name])
    # dovetails_[LR]()
    self.assertEqual([l["a+b+"], l["a+c-"],
                  l["g+a-"], l["i-a-"]], sa.dovetails_R)
    self.assertEqual([l["a-d+"], l["a-e-"],
                  l["f+a+"], l["h-a+"]], sa.dovetails_L)
    # dovetails()
    self.assertEqual(sa.dovetails_R, sa.dovetails_of_end("R"))
    self.assertEqual(sa.dovetails_L, sa.dovetails_of_end("L"))
    self.assertEqual(sa.dovetails_L + sa.dovetails_R, sa.dovetails)
    # neighbours
    self.assertEqual(set(["b", "c", "d", "e", "f", "g", "h", "i"]),
                     set([x.name for x in sa.neighbours]))
    # gfa2 specific collections are empty in gfa1
    self.assertEqual([], sa.gaps)
    self.assertEqual([], sa.fragments)
    self.assertEqual([], sa.internals)
    # upon disconnection
    sa.disconnect()
    self.assertEqual([], sa.dovetails_R)
    self.assertEqual([], sa.dovetails_R)
    self.assertEqual([], sa.dovetails_of_end("L"))
    self.assertEqual([], sa.dovetails_of_end("R"))
    self.assertEqual([], sa.dovetails)
    self.assertEqual([], sa.neighbours)

  def test_containments_references(self):
    g = gfapy.Gfa()
    cab = gfapy.Line("C\ta\t+\tb\t+\t10\t*")
    self.assertEqual("a", cab.from_segment)
    self.assertEqual("b", cab.to_segment)
    sa = gfapy.Line("S\ta\t*")
    g.append(sa)
    sb = gfapy.Line("S\tb\t*")
    g.append(sb)
    g.append(cab)
    self.assertEqual(sa, cab.from_segment)
    self.assertEqual(sb, cab.to_segment)
    cab.disconnect()
    self.assertEqual("a", cab.from_segment)
    self.assertEqual("b", cab.to_segment)
    # disconnection of segment cascades on containments
    g.append(cab)
    assert(cab.is_connected())
    self.assertEqual(sa, cab.from_segment)
    sa.disconnect()
    assert(not cab.is_connected())
    self.assertEqual("a", cab.from_segment)

  def test_containments_backreferences(self):
    g = gfapy.Gfa()
    sa = gfapy.Line("S\ta\t*")
    g.append(sa)
    # containments:
    s = {}; c = {}
    for name in ["b", "c", "d", "e", "f", "g", "h", "i"]:
      s[name] = gfapy.Line("S\t"+"{}".format(name)+"\t*")
      g.append(s[name])
    for name in \
        ["a+b+", "a+c-", "a-d+", "a-e-", "f+a+", "g+a-", "h-a+", "i-a-"]:
      c[name] = gfapy.Line("\t".join(list("C{}9*".format(name))))
      g.append(c[name])
    # edges to contained/containers
    self.assertEqual([c["a+b+"], c["a+c-"], c["a-d+"], c["a-e-"]],
                     sa.edges_to_contained)
    self.assertEqual([c["f+a+"], c["g+a-"], c["h-a+"], c["i-a-"]],
                     sa.edges_to_containers)
    # containments
    self.assertEqual(sa.edges_to_contained + sa.edges_to_containers,
                     sa.containments)
    # contained/containers
    self.assertEqual([s["b"], s["c"], s["d"], s["e"]], sa.contained)
    self.assertEqual([s["f"], s["g"], s["h"], s["i"]], sa.containers)
    # gfa2 specific collections are empty in gfa1
    self.assertEqual([], sa.gaps)
    self.assertEqual([], sa.fragments)
    self.assertEqual([], sa.internals)
    # upon disconnection
    sa.disconnect()
    self.assertEqual([], sa.edges_to_contained)
    self.assertEqual([], sa.edges_to_containers)
    self.assertEqual([], sa.containments)
    self.assertEqual([], sa.contained)
    self.assertEqual([], sa.containers)

