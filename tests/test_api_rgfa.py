import gfapy
import unittest

class TestAPIrGfa(unittest.TestCase):

  def test_adding_invalid_segment_to_rgfa(self):
    gfa = gfapy.Gfa()
    gfa.append("S\t1\t*")
    gfa.validate()
    gfa = gfapy.Gfa(dialect="rgfa")
    gfa.append("S\t1\t*")
    with self.assertRaises(gfapy.NotFoundError): gfa.validate()

  def test_adding_containment_to_rgfa(self):
    gfa = gfapy.Gfa()
    gfa.append("C\t1\t+\t2\t+\t12\t*")
    gfa.validate()
    gfa = gfapy.Gfa(version="gfa1",dialect="rgfa")
    gfa.append("C\t1\t+\t2\t+\t12\t*")
    with self.assertRaises(gfapy.NotFoundError): gfa.validate()

  def test_loading_examples(self):
    gfapy.Gfa.from_file("tests/testdata/rgfa_example.1.gfa", dialect="rgfa")
    gfapy.Gfa.from_file("tests/testdata/rgfa_example.2.gfa", dialect="rgfa")

  def test_stable_sequence_names(self):
    g = gfapy.Gfa.from_file("tests/testdata/rgfa_example.2.gfa", dialect="rgfa")
    self.assertEqual(['smpl-Ref.Bd4', 'smpl-Bd21_3_r.pseudomolecule_4'],
        g.stable_sequence_names)
    g = gfapy.Gfa.from_file("tests/testdata/rgfa_example.1.gfa", dialect="rgfa")
    self.assertEqual(['bar', 'foo', 'chr1'],
        g.stable_sequence_names)
