import gfapy
import unittest

class TestAPIMultiplication(unittest.TestCase):

  def test_multiply_segment(self):
    gfa = gfapy.Gfa()
    gfa.append("H\tVN:Z:1.0")
    s = {"S\t0\t*\tRC:i:600",
         "S\t1\t*\tRC:i:6000",
         "S\t2\t*\tRC:i:60000"}
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    p = "P\t3\t2+,0-\t12M"
    for line in (list(s) + [l,c,p]): gfa.append(line)
    self.assertEqual(s, {str(x) for x in gfa.segments})
    self.assertEqual([l], [str(x) for x in gfa.dovetails if not x.virtual])
    self.assertEqual([c], [str(x) for x in gfa.containments])
    self.assertEqual([l], [str(x) for x in gfa.segment("1").end_relations("R", ["2", "L"])])
    self.assertEqual([c], [str(x) for x in gfa.segment("1").relations_to("0")])
    self.assertEqual(6000, gfa.segment("1").RC)
    gfa.multiply("1", 2)
    self.assertEqual([l], [str(x) for x in gfa.segment("1").end_relations("R", ["2", "L"])])
    self.assertEqual([c], [str(x) for x in gfa.segment("1").relations_to("0")])
    self.assertNotEqual([], [str(x) for x in gfa.segment("1*2").end_relations("R", ["2", "L"])])
    self.assertNotEqual([], [str(x) for x in gfa.segment("1*2").relations_to("0")])
    self.assertEqual(3000, gfa.segment("1").RC)
    self.assertEqual(3000, gfa.segment("1*2").RC)
    gfa.multiply("1*2", 3, copy_names=["6","7"])
    self.assertEqual([l], [str(x) for x in gfa.segment("1").end_relations("R", ["2", "L"])])
    self.assertNotEqual([], [str(x) for x in gfa.segment("1*2").end_relations("R", ["2", "L"])])
    self.assertNotEqual([], [str(x) for x in gfa.segment("6").end_relations("R", ["2", "L"])])
    self.assertNotEqual([], [str(x) for x in gfa.segment("7").end_relations("R", ["2", "L"])])
    self.assertNotEqual([], gfa.segment("1*2").relations_to("0"))
    self.assertNotEqual([], gfa.segment("6").relations_to("0"))
    self.assertNotEqual([], gfa.segment("7").relations_to("0"))
    self.assertEqual(3000, gfa.segment("1").RC)
    self.assertEqual(1000, gfa.segment("1*2").RC)
    self.assertEqual(1000, gfa.segment("6").RC)
    self.assertEqual(1000, gfa.segment("7").RC)

  def test_multiply_segment_copy_names(self):
    gfa = gfapy.Gfa.from_list(["H\tVN:Z:1.0",
           "S\t1\t*\tRC:i:600",
           "S\t1b\t*\tRC:i:6000",
           "S\t2\t*\tRC:i:60000",
           "S\t3\t*\tRC:i:60000"])
    gfa.multiply("2", 2)
    gfa.try_get_segment("2*2") # nothing raised
    gfa.multiply("2*2", 2)
    gfa.try_get_segment("2*3") # nothing raised
    gfa.multiply("2*2", 2, copy_names = ["x"])
    gfa.try_get_segment("x") # nothing raised

  def test_links_distribution_l1_m2(self):
    for sfx in ["gfa", "gfa2"]:
      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l1.{}".format(sfx))
      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l1.m2.{}".format(sfx))
      self.assertNotEqual(set(g2.segment_names),set(g1.segment_names))
      self.assertNotEqual(set([str(x) for x in g2.dovetails]),
                          set([str(x) for x in g1.dovetails]))
      g1.multiply("1", 2, extended=True)
      self.assertEqual(set(g2.segment_names),set(g1.segment_names))
      self.assertEqual(set([str(x) for x in g2.dovetails]),
                       set([str(x) for x in g1.dovetails]))

####  def test_enable_extensions(self):
####    for sfx in ["gfa", "gfa2"]:
####      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l1.{}".format(sfx))
####      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l1.m2.{}".format(sfx))
####      g1.enable_extensions
####      g2.enable_extensions
####      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
####                       [str(x) for x in g1.dovetails].sort)
####      g1.multiply("1", 2)
####      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
####
####  def test_links_distribution_l2_m2(self):
####    for sfx in ["gfa", "gfa2"]:
####      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.{}".format(sfx))
####      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.m2.{}".format(sfx))
####      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
####                       [str(x) for x in g1.dovetails].sort)
####      g1.multiply_extended("1", 2)
####      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
####
####  def test_no_links_distribution_l2_m2(self):
####    for sfx in ["gfa", "gfa2"]:
####      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.{}".format(sfx))
####      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.m2.no_ld.{}".format(sfx))
####      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
####                       [str(x) for x in g1.dovetails].sort)
####      g1.multiply_extended("1", 2, distribute: "off")
####      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
####
####  def test_links_distribution_l2_m3(self):
####    for sfx in ["gfa", "gfa2"]:
####      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.{}".format(sfx))
####      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.m3.{}".format(sfx))
####      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
####                       [str(x) for x in g1.dovetails].sort)
####      g1.multiply_extended("1", 3)
####      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
####
####  def test_no_links_distribution_l2_m3(self):
####    for sfx in ["gfa", "gfa2"]:
####      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.{}".format(sfx))
####      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.m3.no_ld.{}".format(sfx))
####      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
####                       [str(x) for x in g1.dovetails].sort)
####      g1.multiply_extended("1", 3, distribute: "off")
####      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
####
####  def test_links_distribution_l3_m2(self):
####    for sfx in ["gfa", "gfa2"]:
####      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l3.{}".format(sfx))
####      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l3.m2.{}".format(sfx))
####      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
####                       [str(x) for x in g1.dovetails].sort)
####      g1.multiply_extended("1", 2)
####      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
####
####  def test_no_links_distribution_l3_m2(self):
####    for sfx in ["gfa", "gfa2"]:
####      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l3.{}".format(sfx))
####      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l3.m2.no_ld.{}".format(sfx))
####      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
####                       [str(x) for x in g1.dovetails].sort)
####      g1.multiply_extended("1", 2, distribute: "off")
####      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
####      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))

###  def test_muliply_without_rgfatools(self):
###    for sfx in ["gfa", "gfa2"]:
###      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l3.{}".format(sfx))
###      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l3.m2.no_ld.{}".format(sfx))
###      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
###      self.assertNotEqual(g2.dovetails, [str(x) for x in ].sort,
###                       [str(x) for x in g1.dovetails].sort)
###      g1.multiply("1", 2)
###      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))

###  def test_distribution_policy_equal_with_equal(self):
###    for sfx in ["gfa", "gfa2"]:
###      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.{}".format(sfx))
###      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.m2.{}".format(sfx))
###      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
###                       [str(x) for x in g1.dovetails].sort)
###      g1.multiply_extended("1", 2, distribute: "equal")
###      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
###
###  def test_distribution_policy_equal_with_not_equal(self):
###    for sfx in ["gfa", "gfa2"]:
###      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l3.{}".format(sfx))
###      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l3.m2.no_ld.{}".format(sfx))
###      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
###                       [str(x) for x in g1.dovetails].sort)
###      g1.multiply_extended("1", 2, distribute: "equal")
###      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
###
###  def test_distribution_policy_B(self):
###    for sfx in ["gfa", "gfa2"]:
###      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.{}".format(sfx))
###      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.m2.no_ld.{}".format(sfx))
###      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
###                       [str(x) for x in g1.dovetails].sort)
###      g1.multiply_extended("1", 2, distribute: "L")
###      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
###
###  def test_distribution_policy_E(self):
###    for sfx in ["gfa", "gfa2"]:
###      g1 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.{}".format(sfx))
###      g2 = gfapy.Gfa.from_file("test/testdata/links_distri.l2.m2.{}".format(sfx))
###      self.assertNotEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertNotEqual(g2.dovetails].sort,
###                       [str(x) for x in g1.dovetails].sort)
###      g1.multiply_extended("1", 2, distribute: "R")
###      self.assertEqual(g2.segment_names.sort,g1.segment_names.sort)
###      [str(x) for x in self.assertEqual(set(g2.dovetails]), set([str(x) for x in g1.dovetails]))
###
