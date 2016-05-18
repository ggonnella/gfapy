require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFASequence < Test::Unit::TestCase

  def test_rc
    assert_equal("gcatcgatcgt","acgatcgatgc".rc)
    assert_equal("gCaTCgatcgt","acgatcGAtGc".rc)
    assert_equal("gcatcnatcgt","acgatngatgc".rc)
    assert_equal("gcatcYatcgt","acgatRgatgc".rc)
    assert_raises(RuntimeError){"acgatUgatgc".rc}
    assert_equal("gcaucgaucgu","acgaucgaugc".rc)
    assert_equal("===.",".===".rc)
    assert_raises(RuntimeError){"acgatXgatgc".rc}
    assert_equal("*","*".rc)
    assert_raises(RuntimeError){"**".rc}
  end

end
