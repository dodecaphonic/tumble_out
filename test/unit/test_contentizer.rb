require File.join(File.dirname(__FILE__), "..",
                  "test_helper")

class TestContentizer < MiniTest::Unit::TestCase
  def setup
    raw_data = open(
                    File.join(File.dirname(__FILE__), "..",
                              "assets", "sample.xml")
                   )

    Net::HTTP.expects(:get).returns raw_data

    @contentizer = TumbleOut::Contentizer.new("sample.tumblr.com")
  end

  def test_if_number_of_posts_is_correct
    posts = @contentizer.posts

    assert_equal 9, posts.size
  end

  def test_that_post_types_are_of_a_given_count
    types = @contentizer.posts.map { |p| p.type }.uniq

    assert_equal 7, types.size

  end

  def test_whether_posts_are_of_specific_types
    valid_types = [:audio, :regular, :video, :quote, :photo,
                   :answer, :conversation].sort

    post_types = @contentizer.posts.map { |p|
      p.type
    }.uniq.sort

    assert_equal valid_types, post_types
  end

  # TODO: mock the crap out of this.
  def test_that_dump_creates_a_file_for_each_post
    full_path = File.join("/tmp", @contentizer.url,
                          "_posts", "*")

    @contentizer.dump "/tmp"

    files = Dir.glob(full_path)

    assert_equal 9, files.size

    files.each { |f| File.delete f }
  end
end
