require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFASequence < Test::Unit::TestCase

  def test_rc
    assert_equal("gcatcgatcgt","acgatcgatgc".rc)
    assert_equal("gCaTCgatcgt","acgatcGAtGc".rc)
    assert_equal("gcatcnatcgt","acgatngatgc".rc)
    assert_equal("gcatcYatcgt","acgatRgatgc".rc)
    assert_raises(RGFA::InconsistencyError){"acgatUgatgc".rc}
    assert_equal("gcaucgaucgu","acgaucgaugc".rc)
    assert_equal("===.",".===".rc)
    assert_raises(RGFA::ValueError){"acgatXgatgc".rc}
    assert_equal("*","*".rc)
    assert_raises(RGFA::ValueError){"**".rc}
  end

end
