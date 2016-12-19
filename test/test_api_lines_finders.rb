require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
TestAPI::Lines ||= Module.new
class TestAPI::Lines::Finders < Test::Unit::TestCase

  @@l_gfa1 = ["S\t1\t*",
              "S\t2\t*",
              "S\t3\t*",
              "S\t4\tCGAT",
              "L\t1\t+\t2\t+\t*",
              "L\t1\t-\t3\t+\t*",
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


  def test_segment_gfa1
    # existing name as argument
    assert_equal(@@l_gfa1[0],@@gfa1.segment(:"1"))
    assert_equal(@@l_gfa1[0],@@gfa1.segment!(:"1"))
    # not existing name as argument
    assert_equal(nil,@@gfa1.segment(:"0"))
    assert_raises(RGFA::NotFoundError) {@@gfa1.segment!(:"0")}
    # line as argument
    assert_equal(@@l_gfa1[0],@@gfa1.segment(@@l_gfa1[0]))
    assert_equal(@@l_gfa1[0],@@gfa1.segment!(@@l_gfa1[0]))
    # connection to rgfa is not checked if argument is line
    assert_equal(@@l_gfa2[0],@@gfa1.segment(@@l_gfa2[0]))
    assert_equal(@@l_gfa2[0],@@gfa1.segment!(@@l_gfa2[0]))
  end

  def test_segment_gfa2
    # existing name as argument
    assert_equal(@@l_gfa2[0],@@gfa2.segment(:"1"))
    assert_equal(@@l_gfa2[0],@@gfa2.segment!(:"1"))
    # not existing name as argument
    assert_equal(nil,@@gfa2.segment(:"0"))
    assert_raises(RGFA::NotFoundError) {@@gfa2.segment!(:"0")}
    # line as argument
    assert_equal(@@l_gfa2[0],@@gfa2.segment(@@l_gfa2[0]))
    assert_equal(@@l_gfa2[0],@@gfa2.segment!(@@l_gfa2[0]))
    # connection to rgfa is not checked if argument is line
    assert_equal(@@l_gfa1[0],@@gfa2.segment(@@l_gfa1[0]))
    assert_equal(@@l_gfa1[0],@@gfa2.segment!(@@l_gfa1[0]))
  end

  def test_line_gfa1
    # segment name as argument
    assert_equal(@@l_gfa1[0],@@gfa1.line(:"1"))
    assert_equal(@@l_gfa1[0],@@gfa1.line!(:"1"))
    # path name as argument
    assert_equal(@@l_gfa1[7],@@gfa1.line(:"p1"))
    assert_equal(@@l_gfa1[7],@@gfa1.line!(:"p1"))
    # not existing name as argument
    assert_equal(nil,@@gfa1.line(:"0"))
    assert_raises(RGFA::NotFoundError) {@@gfa1.line!(:"0")}
    # line as argument
    assert_equal(@@l_gfa1[0],@@gfa1.line(@@l_gfa1[0]))
    assert_equal(@@l_gfa1[0],@@gfa1.line!(@@l_gfa1[0]))
    # connection to rgfa is not checked if argument is line
    assert_equal(@@l_gfa2[0],@@gfa1.line(@@l_gfa2[0]))
    assert_equal(@@l_gfa2[0],@@gfa1.line!(@@l_gfa2[0]))
  end

  def test_line_gfa2
    # segment name as argument
    assert_equal(@@l_gfa2[0],@@gfa2.line(:"1"))
    assert_equal(@@l_gfa2[0],@@gfa2.line!(:"1"))
    # edge name as argument
    assert_equal(@@l_gfa2[2],@@gfa2.line(:"e1"))
    assert_equal(@@l_gfa2[2],@@gfa2.line!(:"e1"))
    # gap name as argument
    assert_equal(@@l_gfa2[3],@@gfa2.line(:"g1"))
    assert_equal(@@l_gfa2[3],@@gfa2.line!(:"g1"))
    # path name as argument
    assert_equal(@@l_gfa2[4],@@gfa2.line(:"o1"))
    assert_equal(@@l_gfa2[4],@@gfa2.line!(:"o1"))
    # set name as argument
    assert_equal(@@l_gfa2[5],@@gfa2.line(:"u1"))
    assert_equal(@@l_gfa2[5],@@gfa2.line!(:"u1"))
    # not existing name as argument
    assert_equal(nil,@@gfa2.line(:"0"))
    assert_raises(RGFA::NotFoundError) {@@gfa2.line!(:"0")}
    # line as argument
    assert_equal(@@l_gfa2[0],@@gfa2.line(@@l_gfa2[0]))
    assert_equal(@@l_gfa2[0],@@gfa2.line!(@@l_gfa2[0]))
    # connection to rgfa is not checked if argument is line
    assert_equal(@@l_gfa1[0],@@gfa2.line(@@l_gfa1[0]))
    assert_equal(@@l_gfa1[0],@@gfa2.line!(@@l_gfa1[0]))
  end

  def test_fragments_for_external
    assert_equal(@@l_gfa2[6..8], @@gfa2.fragments_for_external(:"read1"))
    assert_equal([], @@gfa2.fragments_for_external(:"read2"))
  end

  def test_select_by_hash_gfa1
    # search segments
    assert_equal(@@l_gfa1[0..3], @@gfa1.select({:record_type => :S,
                                                :sequence => "CGAT"}))
    assert_equal(@@l_gfa1[0..0], @@gfa1.select({:record_type => :S,
                                                :name => :"1"}))
    # search links
    assert_equal(@@l_gfa1[4..4], @@gfa1.select({:record_type => :L,
                                                :from => :"1",
                                                :from_orient => :+}))
    # search containments
    assert_equal(@@l_gfa1[6..6], @@gfa1.select({:record_type => :C,
                                                :from => :"1",
                                                :pos => 1}))
    # search paths
    assert_equal(@@l_gfa1[7..7], @@gfa1.select({:record_type => :P,
                                                :segment_names => "1+,2+"}))
    # no record type specified
    assert_equal(@@l_gfa1[0..0], @@gfa1.select({:name => :"1"}))
    assert_equal(@@l_gfa1[4..6], @@gfa1.select({:from => :"1"}))
    # reference as value
    assert_equal(@@l_gfa1[4..6], @@gfa1.select({:from => @@l_gfa1[0]}))
    # placeholder is equal to any value
    assert_equal(@@l_gfa1[0..2], @@gfa1.select({:sequence => "ACC"}))
  end

  def test_select_by_line_gfa1
    @@l_gfa1.size.times do |i|
      assert_equal(@@l_gfa1[i..i], @@gfa1.select(@@l_gfa1[i]))
    end
  end

  def test_select_by_hash_gfa2
    # search segments
    assert_equal(@@l_gfa2[0..1], @@gfa2.select({:record_type => :S,
                                                :sequence => "CGAT"}))
    assert_equal(@@l_gfa2[1..1], @@gfa2.select({:record_type => :S,
                                                :slen => 110}))
    # search edges
    assert_equal(@@l_gfa2[2..2], @@gfa2.select({:record_type => :E,
                                                :sid1 => OL[:"1",:+]}))
    # search gaps
    assert_equal(@@l_gfa2[3..3], @@gfa2.select({:record_type => :G,
                                                :sid1 => OL[:"1",:-]}))
    assert_equal(@@l_gfa2[11..11], @@gfa2.select({:record_type => :G,
                                                :disp => 2000}))
    # search paths
    assert_equal(@@l_gfa2[4..4], @@gfa2.select({:record_type => :O,
                                                :items => "1+ 2-"}))
    # search sets
    assert_equal(@@l_gfa2[5..5], @@gfa2.select({:record_type => :U,
                                                :name => :"u1"}))
    # search fragments
    assert_equal(@@l_gfa2[6..8], @@gfa2.select({:record_type => :F,
                                                :external => "read1-"}))
    # search custom records
    assert_equal(@@l_gfa2[9..9], @@gfa2.select({:record_type => :X,
                                                :xx => "A"}))
  end

  def test_select_by_line_gfa2
    @@l_gfa2.size.times do |i|
      assert_equal(@@l_gfa2[i..i], @@gfa2.select(@@l_gfa2[i]))
    end
  end

end
