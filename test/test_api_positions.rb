require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Positions < Test::Unit::TestCase

  def test_positions
    # from string and integer
    pos1 = 12.to_lastpos; pos2 = "12$".to_pos
    assert_equal(pos1, pos2)
    assert_kind_of(RGFA::LastPos, pos1)
    assert_kind_of(RGFA::LastPos, pos2)
    # value
    assert_equal(12, pos1.value)
    assert_equal(12, pos2.value)
    assert_equal(12, 12.value)
    # to_pos on string without dollar
    assert_equal(12, "12".to_pos)
    assert_kind_of(Integer, "12".to_pos)
    # to pos: wrong format
    assert_raise (RGFA::FormatError) { "12=".to_pos }
    # 0$ is allowed, although unclear if useful
    assert("0$".to_pos.last?)
    # comparison with integer and string
    assert_equal(RGFA::LastPos.new(10), 10)
    assert_equal(10, RGFA::LastPos.new(10))
    # to_s
    assert_equal("12$", pos1.to_s)
    # to_i
    assert_equal(12, pos1.to_i)
  end

  def test_positions_negative
    # negative values
    assert_raise (RGFA::ValueError) { "-1".to_pos }
    assert_raise (RGFA::ValueError) { "-1$".to_pos }
    # negative values, valid: true
    assert_equal(-1, "-1".to_pos(valid: true))
    assert_kind_of(Integer, "-1".to_pos(valid: true))
    assert_equal(RGFA::LastPos.new(-1), "-1$".to_pos(valid: true))
    assert_equal(RGFA::LastPos.new(-1), -1.to_lastpos(valid: true))
    # validate
    assert_raise (RGFA::ValueError) {"-1$".to_pos(valid: true).validate}
    assert_raise (RGFA::ValueError) {-1.to_lastpos(valid: true).validate}
  end

  def test_positions_first_last
    # first? and last?
    assert(!"0".to_pos.last?)
    assert(!"12".to_pos.last?)
    assert("12$".to_pos.last?)
    assert("0".to_pos.first?)
    assert(!"12".to_pos.first?)
    assert(!"12$".to_pos.first?)
  end

  def test_positions_subtract
    a = "13$".to_pos
    a1 = a - 0
    a2 = a - 1
    assert_equal(13, a1)
    assert_equal(12, a2)
    assert(a1.last?)
    assert(!a2.last?)
  end

end
