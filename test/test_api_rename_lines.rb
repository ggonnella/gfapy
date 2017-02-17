require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::RenameLines < Test::Unit::TestCase

  def test_rename
    gfa = ["S\t0\t*", "S\t1\t*", "S\t2\t*", "L\t0\t+\t2\t-\t12M",
    "C\t1\t+\t0\t+\t12\t12M", "P\t4\t2+,0-\t12M"].to_rgfa
    gfa.segment("0").name = "X"
    assert_raises(RGFA::NotFoundError){gfa.segment!("0")}
    assert_equal([:"X", :"1", :"2"].sort, gfa.segment_names.sort)
    assert_equal("L\tX\t+\t2\t-\t12M", gfa.dovetails[0].to_s)
    assert_equal("C\t1\t+\tX\t+\t12\t12M", gfa.containments[0].to_s)
    assert_equal("P\t4\t2+,X-\t12M", gfa.paths[0].to_s)
    assert_raises(RGFA::NotFoundError){gfa.segment!("0").dovetails_of_end(:R)}
    assert_equal("L\tX\t+\t2\t-\t12M", gfa.segment("X").dovetails_of_end(:R)[0].to_s)
    assert_equal("C\t1\t+\tX\t+\t12\t12M",
                 gfa.segment!("1").edges_to_contained[0].to_s)
    assert_raises(RGFA::NotFoundError){gfa.segment!("0").containers}
    assert_equal("C\t1\t+\tX\t+\t12\t12M",
                 gfa.segment!("X").edges_to_containers[0].to_s)
    assert_equal("P\t4\t2+,X-\t12M", gfa.segment!("X").paths[0].to_s)
  end

end
