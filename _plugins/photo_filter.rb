module Jekyll
  module PhotoFilter
    def photo_filter(files)
      site = @context.registers[:site]
      return PhotoIndex.photos(site) if site

      files
    end
  end
end
Liquid::Template.register_filter(Jekyll::PhotoFilter)
