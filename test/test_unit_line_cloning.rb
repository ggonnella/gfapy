require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::LineCloning < Test::Unit::TestCase

  def test_clone_tags
    l = "H\tVN:Z:1.0".to_rgfa_line
    l1 = l
    l2 = l.clone
    assert_equal(RGFA::Line::Header, l.class)
    assert_equal(RGFA::Line::Header, l2.class)
    l2.VN="2.0"
    assert_equal("2.0", l2.VN)
    assert_equal("1.0", l.VN)
    l1.VN="2.0"
    assert_equal("2.0", l.VN)
  end

  def test_clone_deep_string
    s = "S\t1\tCAGCTTG".to_rgfa_line
    s_clone = s.clone
    assert_equal(s_clone.sequence, s.sequence)
    assert_not_equal(s_clone.sequence.object_id, s.sequence.object_id)
    s_clone.sequence << "CCC"
    assert_not_equal(s_clone.sequence, s.sequence)
  end

  def test_clone_deep_posfield_array
    u = "U\t*\t1 2 3".to_rgfa_line
    u_clone = u.clone
    assert_equal(u_clone.items, u.items)
    assert_not_equal(u_clone.items.object_id, u.items.object_id)
    u_clone.items << "4"
    assert_not_equal(u_clone.items, u.items)
  end

  def test_clone_deep_J_field
    h = "H\txx:J:[1,2,3]".to_rgfa_line
    h_clone = h.clone
    assert_equal(h_clone.xx, h.xx)
    assert_not_equal(h_clone.xx.object_id, h.xx.object_id)
    h_clone.xx[0] += 1
    assert_not_equal(h_clone.xx, h.xx)
  end

  def test_clone_disconnected
    g = RGFA.new
    g << (sA = "S\tA\t7\tCAGCTTG".to_rgfa_line)
    g << (u = "U\t*\tA B C".to_rgfa_line)
    assert(u.connected?)
    assert_equal([u], sA.sets)
    assert_equal([u], g.sets)
    u_clone = u.clone
    assert(!u_clone.connected?)
    assert_equal([u], sA.sets)
    assert_equal([u], g.sets)
    assert_not_equal([:A, :B, :C], u.items)
    assert_equal([:A, :B, :C], u.items.map(&:name))
    assert_equal([:A, :B, :C], u_clone.items)
  end

end
