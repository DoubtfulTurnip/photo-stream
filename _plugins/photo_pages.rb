module Jekyll
  class PhotoPages < Generator
    safe true

    def generate(site)
      PhotoIndex.visible_photos(site).each do |photo|
        site.pages << PhotoPage.new(site, site.source, photo)
      end
    end
  end

  class PhotoPage < Page
    def initialize(site, base, photo)
      name = File.basename(photo["name"], ".*")
      slug = photo["slug"]

      @site = site
      @base = base
      @dir  = slug
      @name = "index.html"

      self.process(@name)
      self.read_yaml(File.join(base), "index.html")

      self.data["title"] = name
      self.data["images"] = [photo]
      self.data["image_slug"] = slug
    end
  end
end
