require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

# note: API public methods are tested in test_api_tags
class TestUnit::NumericArray < Test::Unit::TestCase

  def test_integer_type
    v = {}
    [8,16,32,64,128].each do |b|
      v[b] = 1 << (b/2)
    end
    assert_equal("C", RGFA::NumericArray.integer_type(0..v[8]))
    assert_equal("c", RGFA::NumericArray.integer_type(-1..v[8]))
    assert_equal("S", RGFA::NumericArray.integer_type(0..v[16]))
    assert_equal("s", RGFA::NumericArray.integer_type(-1..v[16]))
    assert_equal("I", RGFA::NumericArray.integer_type(0..v[32]))
    assert_equal("i", RGFA::NumericArray.integer_type(-1..v[32]))
    assert_raise(RGFA::ValueError) {RGFA::NumericArray.integer_type(0..v[64])}
    assert_raise(RGFA::ValueError) {RGFA::NumericArray.integer_type(-1..v[64])}
    assert_raise(RGFA::ValueError) {RGFA::NumericArray.integer_type(0..v[128])}
    assert_raise(RGFA::ValueError) {RGFA::NumericArray.integer_type(-1..v[128])}
  end

end
