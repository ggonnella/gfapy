require_relative "../lib/rgfa.rb"
require "test/unit"
TestUnit ||= Module.new

class TestUnit::Multiplication < Test::Unit::TestCase

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
