require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFATrace < Test::Unit::TestCase

  def test_from_string
    assert_equal(RGFA::Alignment::Trace.new([12,14,15]),"12,14,15".to_trace)
    assert_raises(ArgumentError){"12x,12,12".to_trace}
  end

  def test_validation
    assert_nothing_raised{"12,12,12".to_trace.validate!}
    assert_raises(RGFA::ValueError){
                                    "12,12,12".to_trace.validate!(ts: 10)}
    assert_raises(RGFA::ValueError){"12,-12,12".to_trace.validate!}
    assert_raises(RGFA::TypeError){
                                 RGFA::Alignment::Trace.new(["12x",12,12]).validate!}
  end

  def test_to_s
    assert_equal("12,12,12", RGFA::Alignment::Trace.new([12,12,12]).to_s)
  end

end
