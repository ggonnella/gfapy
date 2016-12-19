require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::SymbolInvert < Test::Unit::TestCase

  def test_invert_orientations
    assert_equal(:+, :-.invert)
    assert_equal(:-, :+.invert)
  end

  def test_invert_segment_ends
    assert_equal(:L, :R.invert)
    assert_equal(:R, :L.invert)
  end

  def test_invert_invalid
    assert_raise(RGFA::ValueError) { :xx.invert }
  end

end
