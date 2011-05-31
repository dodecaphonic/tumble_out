module TumbleOut
  class Post
    attr_reader :type, :date, :format
    attr_accessor :title, :body, :slug

    def initialize(raw_post, use_permalink=false)
      @raw_post = raw_post
      @type  = nil
      @date  = nil
      @format = nil
      @permalink = nil
      @use_permalink = use_permalink
      @title = nil
      @body  = nil
      @slug  = nil
      @topics = nil

      parse raw_post
    end

    def dump(directory)
      full_path = File.join(directory, create_file_name)

      open(full_path, "w") do |f|
        f << create_front_matter
        f << "\n"
        f << @body
      end
    end

    private
    def parse(raw_post)
      @type = raw_post["type"]
      @date = Time.at(raw_post["unix-timestamp"].to_i)
      @slug = raw_post["slug"],
      @format = raw_post["format"]
      @permalink = raw_post["url-with-slug"].scan(/(\/post\/\d+\/\S+)$/)
      @topics = raw_post.search("tag").map { |t| t.text }

      @title, @body = case @type
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

    def create_front_matter
      fm = "---\nlayout:post"
      fm << "\ntitle: #{@title}" if @title
      fm << "\npermalink: #{@permalink}" if @permalink
      fm << "\ntopics: " << @topics.join(" ") unless @topics.empty?
      fm << "\n---"

      fm
    end

    def create_file_name
      if @slug.nil?
        raise StandardError, "Missing slug"
      else
        "#{@date.year}-#{@date.month}-#{@date.day}-#{@slug}.#{@format}"
      end
    end
  end
end
