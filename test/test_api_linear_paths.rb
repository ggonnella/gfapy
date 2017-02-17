require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI||=Module.new

class TestAPI::LinearPaths < Test::Unit::TestCase

  def test_linear_path_merging
    ["gfa", "gfa2"].each do |sfx|
      gfa = RGFA.from_file("testdata/linear_merging.1.#{sfx}")
      assert_raises(RGFA::ValueError) do
        gfa.merge_linear_path([["0", :R],["1", :R],["2", :L],["3", :R]])
      end
      gfa = RGFA.from_file("testdata/linear_merging.2.#{sfx}")
      assert_nothing_raised do
        gfa.merge_linear_path([["0", :R],["1", :R],["2", :L],["3", :R]])
      end
      assert_raises(RGFA::NotFoundError) {gfa.segment!("0")}
      assert_raises(RGFA::NotFoundError) {gfa.segment!("1")}
      assert_raises(RGFA::NotFoundError) {gfa.segment!("2")}
      assert_raises(RGFA::NotFoundError) {gfa.segment!("3")}
      assert_nothing_raised {gfa.segment!("0_1_2_3")}
      assert_equal([], gfa.dovetails)
      assert_equal("ACGACGACGTCGA", gfa.segment("0_1_2_3").sequence)
    end
  end

  def test_linear_path_merge_all
    ["gfa", "gfa2"].each do |sfx|
      gfa = RGFA.from_file("testdata/linear_merging.3.#{sfx}")
      gfa.merge_linear_paths
      assert_nothing_raised { gfa.merge_linear_paths }
      assert_equal([:"0_1_2_3"], gfa.segment_names)
      assert_equal(1, gfa.segments.size)
      assert_equal([], gfa.dovetails)
      gfa = RGFA.from_file("testdata/linear_merging.4.#{sfx}")
      assert_nothing_raised { gfa.merge_linear_paths }
      assert_equal(3, gfa.segments.size)
      assert_equal([:"0",:"3",:"1_2"], gfa.segments.map(&:name))
      gfa = RGFA.from_file("testdata/linear_merging.5.#{sfx}")
      assert_nothing_raised { gfa.merge_linear_paths }
      assert_equal(3, gfa.segments.size)
      assert_equal([:"0", :"1", :"2_3"], gfa.segments.map(&:name))
    end
  end

  def test_linear_path_merge_example1
    ["gfa", "gfa2"].each do |sfx|
      gfa = RGFA.from_file("testdata/example1.#{sfx}")
      assert_equal([%w[18 19 1],
                    %w[11 9 12],
                    %w[22 16 20 21 23]],
                   gfa.linear_paths.map{|sp|sp.map{|sn_et|
                      sn_et.to_segment_end.name.to_s}})
    end
  end

end
