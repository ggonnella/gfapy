require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::RGFALines < Test::Unit::TestCase

  def test_register_line_merge
    g = RGFA.new(version: :gfa1)
    l = RGFA::Line::Header.new({:xx => 1}, version: :gfa1)
    l.instance_variable_set("@rgfa", g)
    assert_nothing_raised { g.register_line(l) }
    assert_equal(1, g.header.xx)
    assert_raise(RGFA::AssertionError) { g.unregister_line(l) }
  end

  def test_register_line_name_present
    g = RGFA.new(version: :gfa1)
    l = RGFA::Line::Segment::GFA1.new({:name => :x}, version: :gfa1)
    l.instance_variable_set("@rgfa", g)
    assert_nothing_raised { g.register_line(l) }
    assert_equal([l], g.segments)
    assert_equal(l, g.line(:x))
    assert_equal([:x], g.segment_names)
    assert_nothing_raised { g.unregister_line(l) }
    assert_equal([], g.segments)
    assert_equal(nil, g.line(:x))
    assert_equal([], g.segment_names)
  end

  def test_register_line_name_absent
    g = RGFA.new(version: :gfa2)
    l = RGFA::Line::Edge::GFA2.new({:eid => RGFA::Placeholder.new},
                                   version: :gfa2)
    l.instance_variable_set("@rgfa", g)
    assert_nothing_raised { g.register_line(l) }
    assert_equal([l], g.edges)
    assert_equal([], g.edge_names)
    assert_nothing_raised { g.unregister_line(l) }
    assert_equal([], g.edges)
  end

  def test_register_line_external
    g = RGFA.new(version: :gfa2)
    l = RGFA::Line::Fragment.new({:external => OL[:x, :+]},
                                  version: :gfa2)
    l.instance_variable_set("@rgfa", g)
    assert_nothing_raised { g.register_line(l) }
    assert_equal([l], g.fragments)
    assert_equal([l], g.fragments_for_external(:x))
    assert_equal([:x], g.external_names)
    assert_nothing_raised { g.unregister_line(l) }
    assert_equal([], g.fragments)
    assert_equal([], g.fragments_for_external(:x))
    assert_equal([], g.external_names)
  end

  def test_register_line_unnamed
    g = RGFA.new(version: :gfa1)
    l = RGFA::Line::Edge::Link.new({}, version: :gfa1)
    l.instance_variable_set("@rgfa", g)
    assert_nothing_raised { g.register_line(l) }
    assert_equal([l], g.dovetails)
    assert_nothing_raised { g.unregister_line(l) }
    assert_equal([], g.dovetails)
  end

end
