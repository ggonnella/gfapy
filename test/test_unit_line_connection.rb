require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::LineConnection < Test::Unit::TestCase

  def test_connected_and_rgfa
    s1 = "S\t1\tACCAT".to_rgfa_line
    assert(!s1.connected?)
    assert_nil(s1.rgfa)
    g = RGFA.new
    g << s1
    assert(s1.connected?)
    assert_equal(g, s1.rgfa)
  end

  def test_connect
    s2 = "S\t2\tACCAT".to_rgfa_line
    assert(!s2.connected?)
    assert_nil(s2.rgfa)
    g = RGFA.new
    s2.connect(g)
    assert(s2.connected?)
    assert_equal(g, s2.rgfa)
  end

  def test_connect_registers_line
    s2 = "S\t2\tACCAT".to_rgfa_line
    g = RGFA.new
    assert_equal([], g.segments)
    s2.connect(g)
    assert_equal([s2], g.segments)
  end

  def test_disconnect
    s1 = "S\t1\tACCAT".to_rgfa_line
    g = RGFA.new
    g << s1
    assert(s1.connected?)
    assert_equal(g, s1.rgfa)
    s1.disconnect
    assert(!s1.connected?)
    assert_nil(s1.rgfa)
  end

  def test_disconnect_unregisters_line
    s1 = "S\t1\tACCAT".to_rgfa_line
    g = RGFA.new
    g << s1
    assert_equal([s1], g.segments)
    s1.disconnect
    assert_equal([], g.segments)
  end

  def test_disconnect_removes_field_backreferences
    s1 = "S\t1\tACCAT".to_rgfa_line
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    g = RGFA.new
    g << s1
    g << l
    assert_equal([l], s1.dovetails)
    l.disconnect
    assert_equal([], s1.dovetails)
  end

  def test_disconnect_removes_field_references
    s1 = "S\t1\tACCAT".to_rgfa_line
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    g = RGFA.new
    g << s1
    g << l
    assert(l.from.eql?(s1))
    l.disconnect
    assert(!l.from.eql?(s1))
    assert_equal(:"1", l.from)
  end

  def test_disconnect_disconnects_dependent_lines
    s1 = "S\t1\tACCAT".to_rgfa_line
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    g = RGFA.new
    g << s1
    g << l
    assert(l.connected?)
    s1.disconnect
    assert(!l.connected?)
  end

  def test_disconnect_removes_nonfield_backreferences
    s1 = "S\t1\tACCAT".to_rgfa_line
    s2 = "S\t2\tCATGG".to_rgfa_line
    s3 = "S\t3\tTGGAA".to_rgfa_line
    l12 = "L\t1\t+\t2\t+\t*".to_rgfa_line
    l23 = "L\t2\t+\t3\t+\t*".to_rgfa_line
    p4 = "P\t4\t1+,2+,3+\t*".to_rgfa_line
    g = RGFA.new
    [s1, s2, s3, l12, l23, p4].each do |line|
      g << line
    end
    assert_equal([p4], l12.paths)
    p4.disconnect
    assert_equal([], l12.paths)
  end

  def test_disconnect_removes_nonfield_references
    s1 = "S\t1\tACCAT".to_rgfa_line
    s2 = "S\t2\tCATGG".to_rgfa_line
    s3 = "S\t3\tTGGAA".to_rgfa_line
    l12 = "L\t1\t+\t2\t+\t*".to_rgfa_line
    l23 = "L\t2\t+\t3\t+\t*".to_rgfa_line
    p4 = "P\t4\t1+,2+,3+\t*".to_rgfa_line
    g = RGFA.new
    [s1, s2, s3, l12, l23, p4].each do |line|
      g << line
    end
    assert_equal([OL[l12,:+],OL[l23,:+]], p4.links)
    p4.disconnect
    assert_equal([], p4.links)
  end

  def test_add_reference
    s1 = "S\t1\tACCAT".to_rgfa_line
    assert_equal([], s1.gaps_L)
    s1.add_reference(:X, :gaps_L)
    assert_equal([:X], s1.gaps_L)
    s1.add_reference(:Y, :gaps_L)
    assert_equal([:X, :Y], s1.gaps_L)
    s1.add_reference(:Z, :gaps_L, append: false)
    assert_equal([:Z, :X, :Y], s1.gaps_L)
  end

  def test_delete_reference
    s1 = "S\t1\tACCAT".to_rgfa_line
    s1.add_reference(:A, :gaps_L)
    s1.add_reference(:B, :gaps_L)
    s1.add_reference(:C, :gaps_L)
    s1.add_reference(:D, :gaps_L)
    s1.add_reference(:E, :gaps_L)
    assert_equal([:A, :B, :C, :D, :E], s1.gaps_L)
    s1.delete_reference(:C, :gaps_L)
    assert_equal([:A, :B, :D, :E], s1.gaps_L)
    s1.delete_first_reference(:gaps_L)
    assert_equal([:B, :D, :E], s1.gaps_L)
    s1.delete_last_reference(:gaps_L)
    assert_equal([:B, :D], s1.gaps_L)
  end

  def test_update_references
    s1 = "S\t1\tACCAT".to_rgfa_line
    gA = RGFA::Line::Gap.new({})
    gnewA = RGFA::Line::Gap.new({})
    gB = RGFA::Line::Gap.new({})
    gC = RGFA::Line::Gap.new({})
    gD = RGFA::Line::Gap.new({})
    gE = RGFA::Line::Gap.new({})
    gX = RGFA::Line::Gap.new({})
    s1.add_reference(gA, :gaps_L)
    s1.add_reference(gB, :gaps_L)
    s1.add_reference(gC, :gaps_L)
    s1.add_reference(gD, :gaps_L)
    s1.add_reference(gE, :gaps_L)
    assert_equal([gA, gB, gC, gD, gE], s1.gaps_L)
    s1.update_references(gA, gnewA, :sid1)
    assert_equal([gnewA, gB, gC, gD, gE], s1.gaps_L)
    s1.update_references(gX, :newX, :sid1)
    assert_equal([gnewA, gB, gC, gD, gE], s1.gaps_L)
    s1.update_references(gB, nil, :sid1)
    assert_equal([gnewA, gC, gD, gE], s1.gaps_L)
  end

end
