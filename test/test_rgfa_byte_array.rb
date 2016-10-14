require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAByteArray < Test::Unit::TestCase

  def test_byte_array_creation
    a, b = nil
    assert_nothing_raised { a = RGFA::ByteArray.new([1,2,3,4,5]) }
    assert_nothing_raised { b = [1,2,3,4,5].to_byte_array }
    assert_equal(a, b)
  end

  def test_byte_array_validation
    a = nil
    assert_nothing_raised { a = RGFA::ByteArray.new([1,2,3,4,5]) }
    assert_nothing_raised { a.validate! }
    assert_nothing_raised { a = RGFA::ByteArray.new([1,2,3,4,356]) }
    assert_raises(RGFA::ValueError) { a.validate! }
  end

  def test_from_string
    a = nil
    assert_nothing_raised { a = "12ACF4AA601C1F".to_byte_array }
    b = [18, 172, 244, 170, 96, 28, 31].to_byte_array
    assert_equal(b, a)
    assert_raises(RGFA::FormatError) {
      a = "12ACF4AA601C1".to_byte_array }
    assert_raises(RGFA::FormatError) {
      a = "".to_byte_array }
    assert_raises(ArgumentError) { a = "12ACG4AA601C1F".to_byte_array }
  end

  def test_to_string
    a = [18, 172, 244, 170, 96, 28, 31].to_byte_array
    b = "12ACF4AA601C1F"
    assert_equal(b, a.to_s)
    a = [18, 172, 280, 170, 96, 28, 31].to_byte_array
    assert_raises(RGFA::ValueError) { a.to_s }
  end

end
