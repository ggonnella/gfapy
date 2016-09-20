require_relative "../lib/rgfatools.rb"
require "test/unit"

class TestRGFAToolsArtifacts < Test::Unit::TestCase

  def test_remove_small_components
    g = RGFA.from_file("test/testdata/two_components.gfa")
    assert_equal(2, g.connected_components.size)
    g.remove_small_components(1000)
    assert_equal(2, g.connected_components.size)
    g.remove_small_components(3000)
    assert_equal(1, g.connected_components.size)
    g.remove_small_components(10000)
    assert_equal(0, g.connected_components.size)
  end

  def test_remove_dead_ends
    g = RGFA.from_file("test/testdata/dead_ends.gfa")
    assert_equal(6, g.segments.size)
    g.remove_dead_ends(100)
    assert_equal(6, g.segments.size)
    g.remove_dead_ends(1500)
    assert_equal(5, g.segments.size)
    g.remove_dead_ends(1500)
    assert_equal(5, g.segments.size)
    g.remove_dead_ends(150000)
    assert_equal(3, g.segments.size)
    g.remove_dead_ends(150000)
    assert_equal(2, g.segments.size)
    g.remove_dead_ends(1500000)
    assert_equal(0, g.segments.size)
  end

end
