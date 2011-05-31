require File.join(File.dirname(__FILE__), "..",
                  "test_helper")

class TestPost < MiniTest::Unit::TestCase
  def setup
    raw_data = open(
                    File.join(File.dirname(__FILE__), "..",
                              "assets", "sample.xml")
                    )

    Net::HTTP.expects(:get).
      with(URI.parse("http://sample.tumblr.com/api/read")).returns raw_data
    contentizer = TumbleOut::Contentizer.new("sample.tumblr.com")
    @posts = contentizer.posts
  end

  def test_if_body_is_set
    assert @posts.all? { |p|
      !((p.body.nil? || p.body.empty?))
    }
  end

  def test_whether_content_matches_type
    convo = @posts.find { |p| p.type == "conversation" }

    doc = Nokogiri::HTML(convo.body)
    ul = doc.search("ul[class=conversation]")
    assert_equal 1, ul.size
    assert_equal 4, ul.search("li").size
  end
end