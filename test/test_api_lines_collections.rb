require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
TestAPI::Lines ||= Module.new

class TestAPI::Lines::Collections < Test::Unit::TestCase

  def test_gfa1_collections
    gfa = RGFA.from_file("testdata/all_line_types.gfa1.gfa")
    # comments
    assert_equal(1, gfa.comments.size)
    assert(gfa.comments[0].content =~ /collections/)
    # containments
    assert_equal(2, gfa.containments.size)
    assert_equal(["2_to_6", "1_to_5"], gfa.containments.map(&:id))
    # dovetails
    assert_equal(4, gfa.dovetails.size)
    assert_equal(["1_to_2", "1_to_3", "11_to_12", "11_to_13"],
                 gfa.dovetails.map(&:id))
    # edges
    assert_equal(6, gfa.edges.size)
    assert_equal(["1_to_2", "1_to_3", "11_to_12",
                  "11_to_13", "2_to_6", "1_to_5"],
                 gfa.edges.map(&:id))
    # segments
    assert_equal([:"1", :"3", :"5", :"13", :"11", :"12", :"4", :"6", :"2"],
                 gfa.segments.map(&:name))
    # segment_names
    assert_equal([:"1", :"3", :"5", :"13", :"11", :"12", :"4", :"6", :"2"],
                 gfa.segment_names)
    # paths
    assert_equal([:"14", :"15"], gfa.paths.map(&:name))
    # path_names
    assert_equal([:"14", :"15"], gfa.path_names)
    # names
    assert_equal(gfa.segment_names + gfa.path_names,
                 gfa.names)
    # lines
    assert_equal(gfa.comments + gfa.headers + gfa.segments + gfa.edges +
                 gfa.paths, gfa.lines)
  end

  def test_gfa2_collections
    gfa = RGFA.from_file("testdata/all_line_types.gfa2.gfa")
    # comments
    assert_equal(3, gfa.comments.size)
    assert(gfa.comments[0].content =~ /collections/)
    # edges
    assert_equal([:"1_to_2", :"2_to_6", :"1_to_3",
                  :"11_to_12", :"11_to_13", :"1_to_5"],
                 gfa.edges.map(&:name))
    # edge_names
    assert_equal([:"1_to_2", :"2_to_6", :"1_to_3",
                  :"11_to_12", :"11_to_13", :"1_to_5"],
                 gfa.edge_names)
    # dovetails
    assert_equal([:"1_to_2", :"1_to_3", :"11_to_12", :"11_to_13"],
                 gfa.dovetails.map(&:name))
    # containments
    assert_equal([:"2_to_6", :"1_to_5"],
                 gfa.containments.map(&:name))
    # gaps
    assert_equal([:"1_to_11", :"2_to_12"], gfa.gaps.map(&:name))
    # gap_names
    assert_equal([:"1_to_11", :"2_to_12"], gfa.gap_names)
    # sets
    assert_equal([:"16", :"16sub"], gfa.sets.map(&:name))
    # set_names
    assert_equal([:"16", :"16sub"], gfa.set_names)
    # paths
    assert_equal([:"14", :"15"], gfa.paths.map(&:name))
    # path_names
    assert_equal([:"14", :"15"], gfa.path_names)
    # segments
    assert_equal([:"1", :"3", :"5", :"13", :"11", :"12", :"4", :"6", :"2"],
                 gfa.segments.map(&:name))
    # segment_names
    assert_equal([:"1", :"3", :"5", :"13", :"11", :"12", :"4", :"6", :"2"],
                 gfa.segment_names)
    # fragments
    assert_equal(["read1_in_2", "read2_in_2"], gfa.fragments.map(&:id))
    # external_names
    assert_equal([:"read1", :"read2"], gfa.external_names)
    # custom_record_keys
    assert_equal([:X, :Y], gfa.custom_record_keys)
    # custom_records
    assert_equal(3, gfa.custom_records.size)
    assert_equal([:X, :X, :Y], gfa.custom_records.map(&:record_type))
    # custom_records(:X)
    assert_equal([:X, :X], gfa.custom_records(:X).map(&:record_type))
    # names
    assert_equal(gfa.segment_names + gfa.edge_names + gfa.gap_names +
                 gfa.path_names + gfa.set_names, gfa.names)
    # lines
    assert_equal(gfa.comments + gfa.headers + gfa.segments + gfa.edges +
                 gfa.paths + gfa.sets + gfa.gaps + gfa.fragments +
                 gfa.custom_records, gfa.lines)
  end
end
