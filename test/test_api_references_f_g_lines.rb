require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
class TestAPI::ReferencesFGLines < Test::Unit::TestCase

  def test_fragments_references
    g = RGFA.new
    f = "F\ta\tf+\t0\t200\t281\t502$\t*".to_rgfa_line
    assert_equal(:a, f.sid)
    assert_equal(OL[:f,:+], f.external)
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    g << f
    assert_equal(sa, f.sid)
    f.disconnect
    assert_equal(:a, f.sid)
    # disconnection of segment cascades on fragments
    g << f
    assert(f.connected?)
    assert_equal(sa, f.sid)
    sa.disconnect
    assert(!f.connected?)
    assert_equal(:a, f.sid)
  end

  def test_fragments_backreferences
    g = RGFA.new
    f1 = "F\ta\tf+\t0\t200\t281\t502$\t*".to_rgfa_line
    f2 = "F\ta\tf+\t240\t440$\t0\t210\t*".to_rgfa_line
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    g << f1
    g << f2
    assert_equal([f1,f2], sa.fragments)
    # disconnection effects
    f1.disconnect
    assert_equal([f2], sa.fragments)
    sa.disconnect
    assert_equal([], sa.fragments)
  end

  def test_gap_references
    g = RGFA.new
    gap = "G\t*\ta+\tb+\t90\t*".to_rgfa_line
    assert_equal(OL[:a,:+], gap.sid1)
    assert_equal(OL[:b,:+], gap.sid2)
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    g << (sb = "S\tb\t100\t*".to_rgfa_line)
    g << gap
    assert_equal(sa, gap.sid1.line)
    assert_equal(sb, gap.sid2.line)
    gap.disconnect
    assert_equal(:a, gap.sid1.line)
    assert_equal(:b, gap.sid2.line)
    # disconnection of segment cascades on gaps
    g << gap
    assert(gap.connected?)
    assert_equal(sa, gap.sid1.line)
    sa.disconnect
    assert(!gap.connected?)
    assert_equal(:a, gap.sid1.line)
  end

  def test_gaps_backreferences
    g = RGFA.new
    g << (sa = "S\ta\t100\t*".to_rgfa_line)
    # gaps
    s = {}; gap = {}
    [:b, :c, :d, :e, :f, :g, :h, :i].each do |name|
      g << (s[name] = "S\t#{name}\t100\t*".to_rgfa_line)
    end
    ["a+b+", "a+c-", "a-d+", "a-e-",
     "f+a+", "g+a-", "h-a+", "i-a-"].each do |name|
      g << (gap[name] =
            ["G","*",name[0..1],name[2..3],200,"*"].join("\t").to_rgfa_line)
    end
    # gaps_[LR]()
    assert_equal([gap["a-d+"], gap["a-e-"], gap["f+a+"], gap["h-a+"]],
                 sa.gaps_L)
    assert_equal([gap["a+b+"], gap["a+c-"], gap["g+a-"], gap["i-a-"]],
                 sa.gaps_R)
    # gaps_of_end()
    assert_equal(sa.gaps_L, sa.gaps_of_end(:L))
    assert_equal(sa.gaps_R, sa.gaps_of_end(:R))
    assert_equal(sa.gaps_L + sa.gaps_R, sa.gaps)
    # disconnection effects
    gap["a-d+"].disconnect
    assert_equal([gap["a-e-"], gap["f+a+"], gap["h-a+"]], sa.gaps_L)
    sa.disconnect
    assert_equal([], sa.gaps_L)
    assert_equal([], sa.gaps_R)
    assert_equal([], sa.gaps_of_end(:L))
    assert_equal([], sa.gaps_of_end(:R))
    assert_equal([], sa.gaps)
  end

end
