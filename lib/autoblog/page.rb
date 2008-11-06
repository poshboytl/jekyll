module AutoBlog

  class Page
    include Convertible
    
    attr_accessor :ext
    attr_accessor :data, :content
    
    # Initialize a new Page.
    #   +base+ is the String path to the <source>
    #   +dir+ is the String path between <source> and the file
    #   +name+ is the String filename of the post file
    #
    # Returns <Page>
    def initialize(base, dir, name)
      @base = base
      @dir = dir
      @name = name
      
      self.data = {}
      
      self.process(name)
      self.read_yaml(File.join(base, dir), name)
      self.set_defaults
      self.transform
    end
    
    # Extract information from the post filename
    #   +name+ is the String filename of the post file
    #
    # Returns nothing
    def process(name)
      self.ext = File.extname(name)
    end
    
    # Set the data defaults.
    #
    # Returns nothing
    def set_defaults
      self.data["layout"] ||= "default"
    end
    
    # Add any necessary layouts to this post
    #   +layouts+ is a Hash of {"name" => "layout"}
    #   +site_payload+ is the site payload hash
    #
    # Returns nothing
    def add_layout(layouts, site_payload)
      payload = {"page" => self.data}.merge(site_payload)
      self.content = Liquid::Template.parse(self.content).render(payload, [AutoBlog::Filters])
      
      layout = layouts[self.data["layout"]] || self.content
      payload = {"content" => self.content, "page" => self.data}
      
      self.content = Liquid::Template.parse(layout).render(payload, [AutoBlog::Filters])
    end
    
    # Write the generated page file to the destination directory.
    #   +dest+ is the String path to the destination dir
    #
    # Returns nothing
    def write(dest)
      FileUtils.mkdir_p(File.join(dest, @dir))
      
      name = @name
      if self.ext != ""
        name = @name.split(".")[0..-2].join('.') + self.ext
      end
      
      path = File.join(dest, @dir, name)
      File.open(path, 'w') do |f|
        f.write(self.content)
      end
    end
  end

end