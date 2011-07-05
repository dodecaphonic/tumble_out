module TumbleOut
  class Post
    attr_reader :type, :date, :format, :title, :body,
                :slug, :permalink, :use_permalink,
                :topics, :assets

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
      @topics  = nil
      @private = false
      @assets  = []
      @coder = HTMLEntities.new

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
      @type = raw_post["type"].strip.to_sym
      @date = Time.at(raw_post["unix-timestamp"].to_i)
      @slug = raw_post["slug"]
      @format = raw_post["format"]
      @permalink = raw_post["url-with-slug"].scan(/(\/post\/\d+\/\S+)$/).flatten.shift
      @topics = raw_post.search("tag").map { |t| t.text }

      @title, @body, @assets = case @type
                               when :audio
                                 parse_audio raw_post
                               when :video
                                 parse_video raw_post
                               when :regular
                                 rt = raw_post.search("regular-title")
                                 rb = raw_post.search("regular-body")

                                 [rt ? rt.text : nil, rb.text, []]
                               when :conversation
                                 parse_conversation raw_post
                               when :quote
                                 qt = raw_post.search("quote-text")
                                 qs = raw_post.search("quote-source")

                                 [nil, "#{qt.text}<br/>#{qs}", []]
                               when :photo
                                 parse_photo raw_post
                               when :answer
                                 parse_answer raw_post
                               end
    end

    # TODO: rewrite to use HTML5 audio + flash fallback
    def parse_audio(post)
      title   = post.search("id3-title").text
      caption = post.search("audio-player")
      assets  = caption.search("embed").map { |n|
        n.attr("src").scan(/audio_file=(.*?)=/).flatten.shift
      }

      body = @coder.decode(caption.inner_html +
                           post.search("audio-caption").
                           inner_html)

      [title, body, assets]
    end

    # TODO: rewrite to use HTML5 video + flash fallback
    def parse_video(post)
      contents = post.search("video-player").first
      scripts  = contents.search("script")

      assets = if scripts.empty?
                 nil
               else
                 URI.extract(scripts.first.text).shift.scan(%r{(http://.*?)\'}).
                   flatten
               end

      body = @coder.decode(contents.inner_html +
                           post.search("video-caption").
                           inner_html)

      [nil, body, assets]
    end

    def parse_conversation(post)
      title = post.search("conversation-title").text
      body  = "<ul class=\"conversation\">\n"

      post.search("conversation line").each { |line|
        body += "\t<li>#{line.attr "label"} #{line.text}"
      }

      body += "</ul>"

      [title, body, nil]
    end

    def parse_answer(post)
      question = post.search("question").text
      answer = @coder.decode(post.search("answer").
                             inner_html)

      body  = "<div class=\"question\">#{question}</div>\n"
      body += "<div class=\"answer\">#{answer}</div>"

      [nil, body, nil]
    end

    def parse_photo(post)
      assets = []

      body = if !(photoset = post.search("photoset photo")).empty?
               photoset.map do |p|
                 src = p.search("photo-url").first.text.strip
                 caption = p.attr("caption")

                 assets << src

                 "<p><img src=\"#{src}\"><br/>#{caption}</p>"
               end.join
             else
               caption = @coder.decode(post.
                                       search("photo-caption").
                                       inner_html)
               src = post.search("photo-url").first.text.strip

               assets << src

               "<img src=\"#{src}\"><br/>#{caption}"
             end

      [nil, body, assets]
    end

    def create_front_matter
      fm = "---\nlayout: post"
      fm << "\ntitle: #{@title}" if @title
      fm << "\npermalink: #{@permalink}" if @use_permalink
      fm << "\ntopics: " << @topics.join(" ") unless @topics.empty?
      fm << "\n---"

      fm
    end

    def create_file_name
      name = (@slug.nil? ||
              @slug.empty?) ? @date.to_i : @slug

      "#{@date.year}-#{@date.month}-#{@date.day}-#{name}.#{@format}"
    end
  end
end
