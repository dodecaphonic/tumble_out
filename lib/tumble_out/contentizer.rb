module TumbleOut
  class Contentizer
    attr_reader :url

    def initialize(url)
      @url = url
      @total_posts = nil
      @chunk_size  = 50
      @posts = []
      @done  = false
    end

    def posts
      until @done
        chunk = raw_posts(@posts.size)
        @posts += chunk.map { |rp| Post.new rp }
        @done = @posts.size == @total_posts
      end

      @posts
    end

    def each_post(&blk)
      all_posts.each &blk
    end

    def dump(directory)
      directory = File.join(directory, @url, "_posts")

      if !File.exist?(directory)
        FileUtils.mkdir_p directory
      end

      posts.each { |p| p.dump directory }
    end

    private
    def raw_posts(offset=0)
      uri = "http://#{@url}/api/read?start=#{offset}"
      doc = Nokogiri::XML(Net::HTTP.get(URI.parse(uri)))

      if @total_posts.nil?
        @total_posts = doc.search("posts").first.
          attr("total").to_i
      end

      doc.search "post"
    end
  end
end
