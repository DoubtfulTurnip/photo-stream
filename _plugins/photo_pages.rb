module Jekyll
  IMAGE_EXTENSIONS = %w[.gif .jpeg .jpg .png .webp].freeze

  class PhotoPages < Generator
    safe true

    def generate(site)
      site.static_files.each do |file|
        if photo_file?(file)
          site.pages << PhotoPage.new(site, site.source, file)
        end
      end
    end

    private

    def photo_file?(file)
      relative_path = file.relative_path.tr("\\", "/").delete_prefix("./").delete_prefix("/")

      relative_path.start_with?("photos/original/") &&
        IMAGE_EXTENSIONS.include?(File.extname(relative_path).downcase)
    end
  end

  class PhotoPage < Page
    def initialize(site, base, file)
      basename = File.basename(file.path)
      name = File.basename(file.path, ".*")
      slug = Jekyll::Utils.slugify(name)

      @site = site
      @base = base
      @dir  = slug
      @name = "index.html"

      self.process(@name)
      self.read_yaml(File.join(base), "index.html")

      self.data["title"] = name
      self.data["images"] = [file]
      self.data["image_slug"] = slug
    end
  end
end
