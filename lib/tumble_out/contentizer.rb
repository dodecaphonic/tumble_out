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
        @posts += chunk.map { |rp| Post.new rp }
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

    def raw_posts(offset=0)
      doc = Nokogiri::XML(Net::HTTP.get(URI.parse("http://#{@url}/api/read")))

      doc.search "post"
    end
  end
end
