require_relative "../lib/rgfa.rb"
require "test/unit"

class (TestUnit||=Module.new)::FieldArray < Test::Unit::TestCase

  def test_initialize
    assert_nothing_raised {RGFA::FieldArray.new(:i, [1,2,3])}
    # no validations performed by default:
    assert_nothing_raised {RGFA::FieldArray.new(:i, [1,2,:a])}
    assert_nothing_raised {RGFA::FieldArray.new(:WRONG, [1,2])}
  end

  def test_datatype
    fa = RGFA::FieldArray.new(:i, [1,2,3])
    assert_equal(:i, fa.datatype)
  end

  def test_validate
    assert_nothing_raised {RGFA::FieldArray.new(:i, [1,2,3]).validate}
    assert_raise(RGFA::TypeError) {
      RGFA::FieldArray.new(:i, [1,2,:a]).validate }
    assert_raise(RGFA::TypeError) {
      RGFA::FieldArray.new(:WRONG, [1,2]).validate }
  end

  def test_validate_gfa_field
    assert_nothing_raised {
      RGFA::FieldArray.new(:i, [1,2,3]).validate_gfa_field(:i) }
    assert_raise(RGFA::TypeError) {
      RGFA::FieldArray.new(:i, [1,2,3]).validate_gfa_field(:J) }
    assert_raise(RGFA::TypeError) {
      RGFA::FieldArray.new(:i, [1,2,:a]).validate_gfa_field(:i) }
    assert_nothing_raised {
      RGFA::FieldArray.new(:WRONG, [1,2]).validate_gfa_field(:i) }
  end

  def test_default_gfa_tag_datatype
    fa = RGFA::FieldArray.new(:Z, ["1","2","3"])
    assert_equal(:Z, fa.default_gfa_tag_datatype)
    # it does not depend on the values: same values, but :i
    fa = RGFA::FieldArray.new(:i, ["1","2","3"])
    assert_equal(:i, fa.default_gfa_tag_datatype)
  end

  def test_to_gfa_field
    fa = RGFA::FieldArray.new(:i, [1,2,3])
    assert_equal("1\t2\t3", fa.to_gfa_field)
  end

  def test_to_gfa_tag
    fa = RGFA::FieldArray.new(:i, [1,2,3])
    assert_equal("xx:i:1\txx:i:2\txx:i:3", fa.to_gfa_tag("xx"))
  end

  def test_vpush
    assert_raise(RGFA::FormatError) {
      RGFA::FieldArray.new(:i, [1,2,3]).vpush("x") }
    assert_raise(RGFA::TypeError) {
      RGFA::FieldArray.new(:i, [1,2,3]).vpush(2.0) }
    assert_raise(RGFA::InconsistencyError) {
      RGFA::FieldArray.new(:i, [1,2,3]).vpush("x", :Z) }
    assert_nothing_raised {
      RGFA::FieldArray.new(:i, [1,2,3]).vpush("x", :i) }
  end

  def test_to_rgfa_field_array
    fa = RGFA::FieldArray.new(:i, [1,2,3])
    assert_equal(fa, fa.to_rgfa_field_array(:Z))
    faz = RGFA::FieldArray.new(:Z, ["1","2","3"])
    assert_not_equal(faz.class, fa.map(&:to_s).class)
    assert_equal(Array, fa.map(&:to_s).class)
    assert_equal(faz, fa.map(&:to_s).to_rgfa_field_array(:Z))
  end

end
