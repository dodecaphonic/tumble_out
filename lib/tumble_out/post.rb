module TumbleOut
  class Post
    attr_reader :type, :date, :format
    attr_accessor :title, :body, :slug

    def initialize(type, date, slug, format="markdown")
      @type  = type
      @date  = date
      @format = format
      @title = nil
      @body  = nil
      @slug  = slug
    end

    def dump(directory)
      full_path = File.join(directory, create_file_name)
      open(full_path, "w") { |f| f << @body }
    end

    private
    def create_file_name
      if @slug.nil?
        raise StandardError, "Missing slug"
      else
        "#{@date.year}-#{@date.month}-#{@date.day}-#{@slug}.markdown"
      end
    end
  end
end
