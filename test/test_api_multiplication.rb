require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Multiplication < Test::Unit::TestCase

  def test_multiply_segment
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    s = ["S\t0\t*\tRC:i:600",
         "S\t1\t*\tRC:i:6000",
         "S\t2\t*\tRC:i:60000"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    p = "P\t3\t2+,0-\t12M"
    (s + [l,c,p]).each {|line| gfa << line }
    assert_equal(s, gfa.segments.map(&:to_s))
    assert_equal([l], gfa.dovetails.select{|n|!n.virtual?}.map(&:to_s))
    assert_equal([c], gfa.containments.map(&:to_s))
    assert_equal([l],
                 gfa.segment(:"1").end_relations(:R, [:"2", :L]).map(&:to_s))
    assert_equal([c], gfa.segment(:"1").relations_to(:"0").map(&:to_s))
    assert_equal(6000, gfa.segment(:"1").RC)
    gfa.multiply(:"1", 2)
    assert_equal([l],
                 gfa.segment(:"1").end_relations(:R, [:"2", :L]).map(&:to_s))
    assert_equal([c], gfa.segment(:"1").relations_to(:"0").map(&:to_s))
    assert_not_equal([],
                gfa.segment(:"1*2").end_relations(:R, [:"2", :L]).map(&:to_s))
    assert_not_equal([], gfa.segment(:"1*2").relations_to(:"0"))
    assert_equal(3000, gfa.segment(:"1").RC)
    assert_equal(3000, gfa.segment(:"1*2").RC)
    gfa.multiply(:"1*2", 3 , copy_names:["6","7"])
    assert_equal([l],
                 gfa.segment(:"1").end_relations(:R, [:"2", :L]).map(&:to_s))
    assert_not_equal([],
                gfa.segment(:"1*2").end_relations(:R, [:"2", :L]).map(&:to_s))
    assert_not_equal([],
                 gfa.segment(:"6").end_relations(:R, [:"2", :L]).map(&:to_s))
    assert_not_equal([],
                 gfa.segment(:"7").end_relations(:R, [:"2", :L]).map(&:to_s))
    assert_not_equal([], gfa.segment(:"1*2").relations_to(:"0"))
    assert_not_equal([], gfa.segment(:"6").relations_to(:"0"))
    assert_not_equal([], gfa.segment(:"7").relations_to(:"0"))
    assert_equal(3000, gfa.segment(:"1").RC)
    assert_equal(1000, gfa.segment(:"1*2").RC)
    assert_equal(1000, gfa.segment(:"6").RC)
    assert_equal(1000, gfa.segment(:"7").RC)
  end

  def test_multiply_segment_copy_names
    gfa = ["H\tVN:Z:1.0",
           "S\t1\t*\tRC:i:600",
           "S\t1b\t*\tRC:i:6000",
           "S\t2\t*\tRC:i:60000",
           "S\t3\t*\tRC:i:60000"].to_rgfa
    gfa.multiply(:"2", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("2B")}
    gfa.multiply(:"2", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("2C")}
    gfa.multiply(:"2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy")}
    gfa.multiply(:"2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy2")}
    gfa.multiply(:"2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy3")}
    gfa.multiply(:"2_copy", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy4")}
    gfa.multiply(:"2_copy4", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy5")}
    gfa.multiply(:"2", 2, copy_names: :number)
    assert_nothing_raised {gfa.segment!("4")}
    gfa.multiply(:"1b", 2)
    assert_nothing_raised {gfa.segment!("1b*2")}
    gfa.multiply(:"1b", 2, copy_names: :number)
    assert_nothing_raised {gfa.segment!("1b2")}
    gfa.multiply(:"1b", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("1b_copy")}
    gfa.multiply(:"1b_copy", 2, copy_names: :lowcase)
    assert_nothing_raised {gfa.segment!("1b_copz")}
    gfa.multiply(:"1b_copy", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("1b_copyB")}
  end

  def test_links_distribution_l1_m2
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l1.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l1.m2.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_enable_extensions
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l1.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l1.m2.#{sfx}")
      g1.enable_extensions
      g2.enable_extensions
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply(:"1", 2)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_links_distribution_l2_m2
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l2.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l2.m2.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_no_links_distribution_l2_m2
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l2.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l2.m2.no_ld.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2, distribute: :off)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_links_distribution_l2_m3
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l2.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l2.m3.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 3)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_no_links_distribution_l2_m3
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l2.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l2.m3.no_ld.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 3, distribute: :off)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_links_distribution_l3_m2
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l3.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l3.m2.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_no_links_distribution_l3_m2
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l3.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l3.m2.no_ld.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2, distribute: :off)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_muliply_without_rgfatools
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l3.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l3.m2.no_ld.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply(:"1", 2)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_distribution_policy_equal_with_equal
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l2.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l2.m2.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2, distribute: :equal)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_distribution_policy_equal_with_not_equal
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l3.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l3.m2.no_ld.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2, distribute: :equal)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_distribution_policy_B
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l2.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l2.m2.no_ld.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2, distribute: :L)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

  def test_distribution_policy_E
    ["gfa", "gfa2"].each do |sfx|
      g1 = RGFA.from_file("testdata/links_distri.l2.#{sfx}")
      g2 = RGFA.from_file("testdata/links_distri.l2.m2.#{sfx}")
      assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_not_equal(g2.dovetails.map(&:to_s).sort,
                       g1.dovetails.map(&:to_s).sort)
      g1.multiply_extended(:"1", 2, distribute: :R)
      assert_equal(g2.segment_names.sort,g1.segment_names.sort)
      assert_equal(g2.dovetails.map(&:to_s).sort, g1.dovetails.map(&:to_s).sort)
    end
  end

end
