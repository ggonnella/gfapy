require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::LineDiff < Test::Unit::TestCase

  def test_line_diff_two_segments
    a = "S\tA\t*\tLN:i:200\txx:Z:a".to_rgfa_line
    b = "S\tB\t*\tLN:i:100".to_rgfa_line
    adiffb = [[:different, :positional_field, :name, "A", "B"],
              [:exclusive, :<, :tag, :xx, :Z, "a"],
              [:different, :tag, :LN, :i, "200", :i, "100"]]
    assert_equal(adiffb, a.diff(b))
    bdiffa = [[:different, :positional_field, :name, "B", "A"],
              [:exclusive, :>, :tag, :xx, :Z, "a"],
              [:different, :tag, :LN, :i, "100", :i, "200"]]
    assert_equal(bdiffa, b.diff(a))
    assert_equal([], a.diff(a))
    assert_equal([], b.diff(b))
  end

  def test_line_diffscript_two_segments
    a = "S\tA\t*\tLN:i:200\txx:Z:a".to_rgfa_line
    b = "S\tB\t*\tLN:i:100".to_rgfa_line
    eval(a.diffscript(b, "a"))
    assert_equal(b.to_s, a.to_s)
    a = "S\tA\t*\tLN:i:200\txx:Z:a".to_rgfa_line
    b = "S\tB\t*\tLN:i:100".to_rgfa_line
    eval(b.diffscript(a, "b"))
    assert_equal(a.to_s, b.to_s)
  end

end
