import gfapy
import unittest

class TestAPILinesCollections(unittest.TestCase):

  def test_gfa1_collections(self):
    gfa = gfapy.Gfa.from_file("tests/testdata/all_line_types.gfa1.gfa")
    # comments
    self.assertEqual(1, len(gfa.comments))
    self.assertRegex(gfa.comments[0].content, r'collections')
    # containments
    self.assertEqual(2, len(gfa.containments))
    self.assertEqual({"2_to_6", "1_to_5"}, {x.name for x in gfa.containments})
    # dovetails
    self.assertEqual(4, len(gfa.dovetails))
    self.assertEqual(set(["1_to_2", "1_to_3", "11_to_12", "11_to_13"]),
                 set([x.name for x in gfa.dovetails]))
    # edges
    self.assertEqual(6, len(gfa.edges))
    self.assertEqual(set(["1_to_2", "1_to_3", "11_to_12",
                  "11_to_13", "2_to_6", "1_to_5"]),
                 set([x.name for x in gfa.edges]))
    # segments
    self.assertSetEqual(set(["1", "3", "5", "13", "11", "12", "4", "6", "2"]),
                 set([x.name for x in gfa.segments]))
    # segment_names
    self.assertSetEqual(set(["1", "3", "5", "13", "11", "12", "4", "6", "2"]),
                 set(gfa.segment_names))
    # paths
    self.assertSetEqual(set(["14", "15"]), set([x.name for x in gfa.paths]))
    # path_names
    self.assertSetEqual(set(["14", "15"]), set(gfa.path_names))
    # names
    self.assertSetEqual(set(gfa.segment_names + gfa.path_names +
                        gfa.edge_names), set(gfa.names))
    # lines
    self.assertEqual(set([str(x) for x in gfa.comments + gfa.headers + gfa.segments + gfa.edges +
                 gfa.paths]), set([str(x) for x in gfa.lines]))

  def test_gfa2_collections(self):
    gfa = gfapy.Gfa.from_file("tests/testdata/all_line_types.gfa2.gfa")
    # comments
    self.assertEqual(3, len(gfa.comments))
    self.assertRegex(gfa.comments[0].content, r'collections')
    # edges
    self.assertSetEqual(set(["1_to_2", "2_to_6", "1_to_3",
                  "11_to_12", "11_to_13", "1_to_5"]),
                 set([x.name for x in gfa.edges]))
    # edge_names
    self.assertSetEqual(set(["1_to_2", "2_to_6", "1_to_3",
                  "11_to_12", "11_to_13", "1_to_5"]),
                 set(gfa.edge_names))
    # dovetails
    self.assertSetEqual(set(["1_to_2", "1_to_3", "11_to_12", "11_to_13"]),
                 set([x.name for x in gfa.dovetails]))
    # containments
    self.assertSetEqual(set(["2_to_6", "1_to_5"]),
                 set([x.name for x in gfa.containments]))
    # gaps
    self.assertSetEqual(set(["1_to_11", "2_to_12"]), set([x.name for x in gfa.gaps]))
    # gap_names
    self.assertSetEqual(set(["1_to_11", "2_to_12"]), set(gfa.gap_names))
    # sets
    self.assertSetEqual(set(["16", "16sub"]), set([x.name for x in gfa.sets]))
    # set_names
    self.assertSetEqual(set(["16", "16sub"]), set(gfa.set_names))
    # paths
    self.assertSetEqual(set(["14", "15"]), set([x.name for x in gfa.paths]))
    # path_names
    self.assertSetEqual(set(["14", "15"]), set(gfa.path_names))
    # segments
    self.assertSetEqual(set(["1", "3", "5", "13", "11", "12", "4", "6", "2"]),
               set([x.name for x in gfa.segments]))
    # segment_names
    self.assertSetEqual(set(["1", "3", "5", "13", "11", "12", "4", "6", "2"]),
               set(gfa.segment_names))
    # fragments
    self.assertSetEqual(set(["read1_in_2", "read2_in_2"]),
        set([x.get("id") for x in gfa.fragments]))
    # external_names
    self.assertSetEqual(set(["read1", "read2"]), set(gfa.external_names))
    # custom_record_keys
    self.assertSetEqual(set(["X", "Y"]), set(gfa.custom_record_keys))
    # custom_records
    self.assertEqual(3, len(gfa.custom_records))
    self.assertSetEqual(set(["X", "X", "Y"]), set([x.record_type for x in gfa.custom_records]))
    # custom_records("X")
    self.assertSetEqual(set(["X", "X"]), set([x.record_type for x in gfa.custom_records_of_type("X")]))
    # names
    self.assertSetEqual(set(gfa.segment_names + gfa.edge_names + gfa.gap_names +
                 gfa.path_names + gfa.set_names), set(gfa.names))
    # lines
    self.assertSetEqual(set([str(x) for x in gfa.comments + gfa.headers + gfa.segments + gfa.edges +
                 gfa.paths + gfa.sets + gfa.gaps + gfa.fragments +
                 gfa.custom_records]), set([str(x) for x in gfa.lines]))
