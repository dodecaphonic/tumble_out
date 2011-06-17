module TumbleOut
  class Contentizer
    attr_reader :url

    DEFAULTS = {
      use_permalinks: false,
      show_progress: false
    }

    def initialize(url, options={})
      options = DEFAULTS.merge(options)

      @url = url
      @total_posts = nil
      @chunk_size  = 50
      @posts = []
      @done  = false
      @use_permalinks = options[:use_permalinks]
      @show_progress = options[:show_progress]
    end

    def posts
      $stderr.puts "Exporting..." if @show_progress

      until @done
        chunk = raw_posts(@posts.size)
        @posts += chunk.map { |rp|
          Post.new rp, @use_permalinks
        }
        @done = @posts.size == @total_posts

        $stderr.print "\r#{@posts.size} of #{@total_posts}" if @show_progress
      end

      puts if @show_progress

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
