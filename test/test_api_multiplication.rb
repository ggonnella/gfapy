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
    assert_equal([l], gfa.links.select{|n|!n.virtual?}.map(&:to_s))
    assert_equal([c], gfa.containments.map(&:to_s))
    assert_equal(l, gfa.link(["1", :R], ["2", :L]).to_s)
    assert_equal(c, gfa.containments_between("1", "0")[0].to_s)
    assert_raises(RGFA::NotFoundError){gfa.link(["1a", :R], ["2", :L])}
    assert_raises(RGFA::NotFoundError){gfa.containments_between("5", "0")}
    assert_equal(6000, gfa.segment("1").RC)
    gfa.multiply("1", 2)
    assert_equal(l, gfa.link(["1", :R], ["2", :L]).to_s)
    assert_equal(c, gfa.containments_between("1", "0")[0].to_s)
    assert_not_equal(nil, gfa.link(["1b", :R], ["2", :L]))
    assert_not_equal([], gfa.containments_between("1b", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(3000, gfa.segment("1b").RC)
    gfa.multiply("1b", 3 , copy_names:["6","7"])
    assert_equal(l, gfa.link(["1", :R], ["2", :L]).to_s)
    assert_not_equal(nil, gfa.link(["1b", :R], ["2", :L]))
    assert_not_equal(nil, gfa.link(["6", :R], ["2", :L]))
    assert_not_equal(nil, gfa.link(["7", :R], ["2", :L]))
    assert_not_equal([], gfa.containments_between("1b", "0"))
    assert_not_equal([], gfa.containments_between("6", "0"))
    assert_not_equal([], gfa.containments_between("7", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(1000, gfa.segment("1b").RC)
    assert_equal(1000, gfa.segment("6").RC)
    assert_equal(1000, gfa.segment("7").RC)
  end

  def test_multiply_segment_copy_names
    gfa = ["H\tVN:Z:1.0",
           "S\t1\t*\tRC:i:600",
           "S\t1b\t*\tRC:i:6000",
           "S\t2\t*\tRC:i:60000",
           "S\t3\t*\tRC:i:60000"].to_rgfa
    gfa.multiply("2", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("2B")}
    gfa.multiply("2", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("2C")}
    gfa.multiply("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy")}
    gfa.multiply("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy2")}
    gfa.multiply("2", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy3")}
    gfa.multiply("2_copy", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy4")}
    gfa.multiply("2_copy4", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("2_copy5")}
    gfa.multiply("2", 2, copy_names: :number)
    assert_nothing_raised {gfa.segment!("4")}
    gfa.multiply("1b", 2)
    assert_nothing_raised {gfa.segment!("1c")}
    gfa.multiply("1b", 2, copy_names: :number)
    assert_nothing_raised {gfa.segment!("1b2")}
    gfa.multiply("1b", 2, copy_names: :copy)
    assert_nothing_raised {gfa.segment!("1b_copy")}
    gfa.multiply("1b_copy", 2, copy_names: :lowcase)
    assert_nothing_raised {gfa.segment!("1b_copz")}
    gfa.multiply("1b_copy", 2, copy_names: :upcase)
    assert_nothing_raised {gfa.segment!("1b_copyB")}
  end

  def test_links_distribution_l1_m2
    g1 = RGFA.from_file("test/testdata/links_distri.l1.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l1.m2.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_enable_extensions
    g1 = RGFA.from_file("test/testdata/links_distri.l1.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l1.m2.gfa")
    g1.enable_extensions
    g2.enable_extensions
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply(:"1", 2)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_links_distribution_l2_m2
    g1 = RGFA.from_file("test/testdata/links_distri.l2.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l2.m2.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_no_links_distribution_l2_m2
    g1 = RGFA.from_file("test/testdata/links_distri.l2.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l2.m2.no_ld.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2, distribute: :off)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_links_distribution_l2_m3
    g1 = RGFA.from_file("test/testdata/links_distri.l2.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l2.m3.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 3)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_no_links_distribution_l2_m3
    g1 = RGFA.from_file("test/testdata/links_distri.l2.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l2.m3.no_ld.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 3, distribute: :off)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_links_distribution_l3_m2
    g1 = RGFA.from_file("test/testdata/links_distri.l3.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l3.m2.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_no_links_distribution_l3_m2
    g1 = RGFA.from_file("test/testdata/links_distri.l3.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l3.m2.no_ld.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2, distribute: :off)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_muliply_without_rgfatools
    g1 = RGFA.from_file("test/testdata/links_distri.l3.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l3.m2.no_ld.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply(:"1", 2)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_distribution_policy_equal_with_equal
    g1 = RGFA.from_file("test/testdata/links_distri.l2.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l2.m2.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2, distribute: :equal)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_distribution_policy_equal_with_not_equal
    g1 = RGFA.from_file("test/testdata/links_distri.l3.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l3.m2.no_ld.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2, distribute: :equal)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_distribution_policy_B
    g1 = RGFA.from_file("test/testdata/links_distri.l2.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l2.m2.no_ld.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2, distribute: :L)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_distribution_policy_E
    g1 = RGFA.from_file("test/testdata/links_distri.l2.gfa")
    g2 = RGFA.from_file("test/testdata/links_distri.l2.m2.gfa")
    assert_not_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_not_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
    g1.multiply_extended(:"1", 2, distribute: :R)
    assert_equal(g2.segment_names.sort,g1.segment_names.sort)
    assert_equal(g2.links.map(&:to_s).sort, g1.links.map(&:to_s).sort)
  end

  def test_auto_select_distribute_end_lB_eq_lE
    g = RGFA.new
    # lB == lE == 1
    assert_equal(nil, g.send(:auto_select_distribute_end, 4, 1, 1, false))
    # lB == lE == factor
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 4, 4, false))
    # lB == lE; </> factor
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 2, 2, false))
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 6, 6, false))
  end

  def test_auto_select_distribute_end_l_1
    g = RGFA.new
    # lB or lE == 1, other </==/> factor
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 2, 1, false))
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 4, 1, false))
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 6, 1, false))
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 1, 2, false))
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 1, 4, false))
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 1, 6, false))
  end

  def test_auto_select_distribute_end_eq_factor
    g = RGFA.new
    # one =, one > factor
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 4, 5, false))
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 5, 4, false))
    # one =, one < factor
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 4, 3, false))
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 3, 4, false))
  end

  def test_auto_select_distribute_end_diff_factor
    g = RGFA.new
    # both > 1; both < factor
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 3, 2, false))
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 2, 3, false))
    # both > 1; both > factor
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 5, 6, false))
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 6, 5, false))
    # both > 1; one <, one > factor
    assert_equal(:L, g.send(:auto_select_distribute_end, 4, 3, 5, false))
    assert_equal(:R, g.send(:auto_select_distribute_end, 4, 5, 3, false))
  end

end
