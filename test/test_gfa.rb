require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFA < Test::Unit::TestCase

  def test_new
    gfa = GFA.new
    assert(gfa)
  end

end
