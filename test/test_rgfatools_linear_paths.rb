require_relative "../lib/rgfatools.rb"
require "test/unit"

class TestRGFAToolsLinearPaths < Test::Unit::TestCase

  def test_linear_path_merging
    ["gfa", "gfa2"].each do |sfx|
      gfa = RGFA.from_file("testdata/linear_merging.2.#{sfx}")
      gfa.merge_linear_path([["0", :R],["1", :R],["2", :L],["3", :R]],
                            enable_tracking: true)
      assert_nothing_raised {gfa.segment!("0_1_2^_3")}
      assert_equal("ACGACGACGTCGA", gfa.segment("0_1_2^_3").sequence)
      gfa = RGFA.from_file("testdata/linear_merging.2.#{sfx}")
      gfa.enable_extensions
      gfa.merge_linear_path([["0", :R],["1", :R],["2", :L],["3", :R]])
      assert_nothing_raised {gfa.segment!("0_1_2^_3")}
      assert_equal("ACGACGACGTCGA", gfa.segment("0_1_2^_3").sequence)
    end
  end

  def test_linear_path_merge_all
    ["gfa", "gfa2"].each do |sfx|
      gfa = RGFA.from_file("testdata/linear_merging.3.#{sfx}")
      gfa.enable_extensions
      gfa.merge_linear_paths
      assert_equal([:"0_1_2^_3"], gfa.segment_names)
      gfa = RGFA.from_file("testdata/linear_merging.4.#{sfx}")
      gfa.enable_extensions
      gfa.merge_linear_paths
      assert_equal([:"0",:"3",:"1_2^"], gfa.segments.map(&:name))
    end
  end

end
