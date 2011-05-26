require 'minitest/autorun'
require 'mocha'

require File.join(File.dirname(__FILE__), "..", "..", "lib", "tumble_out")

class TestContentizer < MiniTest::Unit::TestCase
  def setup
    raw_data = open(
                    File.join(File.dirname(__FILE__), "..",
                              "assets", "sample.xml")
                    )
    
    Net::HTTP.expects(:get).
      with(URI.parse("http://sample.tumblr.com/api/read")).returns raw_data
    @contentizer = TumbleOut::Contentizer.new("sample.tumblr.com")
  end

  def test_if_number_of_posts_is_correct
    posts = @contentizer.posts
    
    assert_equal 7, posts.size
  end

  def test_that_post_types_are_of_a_given_count
    types = @contentizer.posts.map { |p| p.type }

    assert_equal 7, types.size
    
  end

  def test_whether_posts_are_of_specific_types
    valid_types = %w(audio regular video quote photo
                     answer conversation).sort
    post_types = @contentizer.posts.map { |p|
      p.type
    }.uniq.sort
    
    assert_equal valid_types, post_types
  end

  def test_that_dump_creates_a_file_for_each_post
    full_path = File.join("/tmp", @contentizer.url,
                          "posts", "*.markdown")

    @contentizer.dump "/tmp"

    assert_equal 7, Dir.glob(full_path).size
  end
end
