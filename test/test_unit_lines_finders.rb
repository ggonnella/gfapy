require_relative "../lib/rgfa.rb"
require "test/unit"
TestUnit ||= Module.new

# note: public methods are tested in test_api_lines_finders
class TestUnit::LinesFinders < Test::Unit::TestCase

  @@l_gfa1 = ["S\t1\t*",
              "S\t2\t*",
              "S\t3\t*",
              "S\t4\tCGAT",
              "L\t1\t+\t2\t+\t*",
              "L\t1\t-\t3\t+\t10M",
              "C\t1\t-\t4\t-\t1\t*",
              "P\tp1\t1+,2+\t*"].map(&:to_rgfa_line)
  @@l_gfa2 = ["S\t1\t100\t*",
              "S\t2\t110\t*",
              "E\te1\t1+\t2-\t0\t100$\t10\t110$\t*",
              "G\tg1\t1-\t2-\t1000\t*",
              "O\to1\t1+ 2-",
              "U\tu1\t1 e1",
              "F\t1\tread1-\t0\t10\t102\t122\t*",
              "F\t1\tread1-\t30\t100$\t180\t255\t*",
              "F\t2\tread1-\t40\t50\t52\t64\t*",
              "X\tx1\txx:Z:A",
              "X\tx2",
              "G\t*\t1+\t2+\t2000\t*"].map(&:to_rgfa_line)
  @@gfa1 = @@l_gfa1.to_rgfa
  @@gfa2 = @@l_gfa2.to_rgfa

  def test_search_link
    # search using the direct link
    assert_equal(@@l_gfa1[4], @@gfa1.search_link(OL[:"1",:+], OL[:"2",:+], "*"))
    # search using the complement link
    assert_equal(@@l_gfa1[4], @@gfa1.search_link(OL[:"2",:-], OL[:"1",:-], "*"))
    # with cigar parameter, but placeholder in line
    assert_equal(@@l_gfa1[4],
                 @@gfa1.search_link(OL[:"1",:+], OL[:"2",:+], "10M"))
    # with cigar parameter, and cigar in line
    assert_equal(@@l_gfa1[5],
                 @@gfa1.search_link(OL[:"1",:-], OL[:"3",:+], "10M"))
    assert_equal(nil,
                 @@gfa1.search_link(OL[:"1",:-], OL[:"3",:+], "12M"))
    # with placeholder parameter, and cigar in line
    assert_equal(@@l_gfa1[5],
                 @@gfa1.search_link(OL[:"1",:-], OL[:"3",:+], "*"))
  end

  def test_search_duplicate_gfa1
    # link
    assert_equal(@@l_gfa1[4], @@gfa1.search_duplicate(@@l_gfa1[4]))
    # complement link
    assert_equal(@@l_gfa1[4], @@gfa1.search_duplicate(@@l_gfa1[4].complement))
    # containment
    assert_equal(nil, @@gfa1.search_duplicate(@@l_gfa1[6]))
    # segment
    assert_equal(@@l_gfa1[0], @@gfa1.search_duplicate(@@l_gfa1[0]))
    # path
    assert_equal(@@l_gfa1[7], @@gfa1.search_duplicate(@@l_gfa1[7]))
  end

  def test_search_duplicate_gfa2
    # line with mandatory name
    assert_equal(@@l_gfa2[0], @@gfa2.search_duplicate(@@l_gfa2[0]))
    # line with optional name, present
    assert_equal(@@l_gfa2[2], @@gfa2.search_duplicate(@@l_gfa2[2]))
    assert_equal(@@l_gfa2[3], @@gfa2.search_duplicate(@@l_gfa2[3]))
    assert_equal(@@l_gfa2[4], @@gfa2.search_duplicate(@@l_gfa2[4]))
    assert_equal(@@l_gfa2[5], @@gfa2.search_duplicate(@@l_gfa2[5]))
    # line with optional name, not present
    assert_equal(nil, @@gfa2.search_duplicate(@@l_gfa2[11]))
    # line with no name
    assert_equal(nil, @@gfa2.search_duplicate(@@l_gfa2[6]))
    assert_equal(nil, @@gfa2.search_duplicate(@@l_gfa2[9]))
  end

end
