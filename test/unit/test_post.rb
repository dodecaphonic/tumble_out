require File.join(File.dirname(__FILE__), "..",
                  "test_helper")

class TestPost < MiniTest::Unit::TestCase
  def setup
    raw_data = open(
                    File.join(File.dirname(__FILE__), "..",
                              "assets", "sample.xml")
                    )

    Net::HTTP.expects(:get).returns raw_data

    contentizer = TumbleOut::Contentizer.new("sample.tumblr.com")

    @posts = contentizer.posts
  end

  def test_if_body_is_set
    assert @posts.all? { |p|
      !((p.body.nil? || p.body.empty?))
    }
  end

  def test_whether_content_matches_type
    convo = @posts.find { |p| p.type == :conversation }

    doc = Nokogiri::HTML(convo.body)
    ul = doc.search("ul[class=conversation]")
    assert_equal 1, ul.size
    assert_equal 4, ul.search("li").size
  end

  def test_if_tags_match_sample_data
    tagged = @posts.find { |p| !p.topics.empty? }

    assert_equal %w(Berlin startup), tagged.topics
  end

  def test_if_photoset_has_been_parsed
    photoset = @posts.find { |p| p.type == :photo }
    doc = Nokogiri::HTML(photoset.body)

    assert_equal 2, doc.search("img").size
  end

  def test_if_list_of_assets_is_generated_correctly
    photos   = @posts.select { |p| p.type == :photo }
    photo    = photos.last
    photoset = photos.first
    video    = @posts.find { |p| p.type == :video }
    audio    = @posts.find { |p| p.type == :audio }

    assert_equal ['http://sample.tumblr.com/photo/1280/1/1/tumblr_lkvvrj3U2s1qaeuyt'],
                 photo.assets
    assert_equal ['http://blog.mareenfischinger.com/photo/1280/4956577203/1/tumblr_lk9jzhrEYC1qz5f4r',
                  'http://blog.mareenfischinger.com/photo/1280/4956577203/2/tumblr_lk9jzhrEYC1qz5f4r'],
                 photoset.assets
    assert_equal ['http://www.tumblr.com/audio_file/5863286892/tumblr_llr1crZHWZ1qz8306'],
                 audio.assets
    assert_equal ['http://sample.tumblr.com/video_file/7271539734/tumblr_lnvji6Kfru1qzn59d'],
                 video.assets

  end
end
