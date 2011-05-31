module TumbleOut
  class Contentizer
    attr_reader :url

    def initialize(url)
      @url = url
      @total_posts = 0
      @chunk_size  = 50
      @posts = []
      @done  = false
    end

    def posts
      unless @done
        chunk = raw_posts(@posts.size)
        @posts += chunk.map { |rp| parse rp }
      end

      @posts
    end

    def each_post(&blk)
      all_posts.each &blk
    end

    def dump(directory)
      directory = File.join(directory, @url, "posts")

      if !File.exist?(directory)
        FileUtils.mkdir_p directory
      end

      posts.each { |p| p.dump directory }
    end

    private
    def parse(raw_post)
      post = Post.new(raw_post["type"],
                      Time.at(raw_post["unix-timestamp"].to_i),
                      raw_post["slug"],
                      raw_post["format"])

      title, body = case post.type
                    when "audio"
                      parse_audio raw_post
                    when "video"
                      parse_video raw_post
                    when "regular"
                      rt = raw_post.search("regular-title")
                      rb = raw_post.search("regular-body")

                      [rt ? rt.text : nil, rb.text]
                    when "conversation"
                      parse_conversation raw_post
                    when "quote"
                      qt = raw_post.search("quote-text")
                      qs = raw_post.search("quote-source")

                      [nil, "#{qt.text}<br/>#{qs}"]
                    when "photo"
                      parse_photo raw_post
                    when "answer"
                      parse_answer raw_post
                    end

      post.title = title
      post.body  = body

      post
    end

    def parse_audio(post)
      title = post.search("id3-title").text
      body = post.search("audio-player").inner_html +
        post.search("audio-caption").inner_html

      [title, body]
    end

    def parse_video(post)
      body = post.search("video-source").inner_html +
        post.search("video-caption").inner_html

      [nil, body]
    end

    def parse_conversation(post)
      title = post.search("conversation-title").text
      body  = "<ul class=\"conversation\">\n"

      post.search("conversation line").each { |line|
        body += "\t<li>#{line.attr "label"} #{line.text}"
      }

      body += "</ul>"

      [title, body]
    end

    def parse_answer(post)
      question = post.search("question").text
      answer = post.search("answer").inner_html

      body  = "<div class=\"question\">#{question}</div>\n"
      body += "<div class=\"answer\">#{answer}</div>"

      [nil, body]
    end

    def parse_photo(post)
      src  = post.search("photo-url").text
      caption = post.search("photo-caption").inner_html
      body = "<img src=\"#{src}\"><br/>#{caption}"

      [nil, body]
    end

    def raw_posts(offset=0)
      doc = Nokogiri::XML(Net::HTTP.get(URI.parse("http://#{@url}/api/read")))

      doc.search "post"
    end
  end
end
