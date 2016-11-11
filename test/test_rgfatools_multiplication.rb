require_relative "../lib/rgfatools.rb"
require "test/unit"

class TestRGFAToolsMuliplication < Test::Unit::TestCase

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
