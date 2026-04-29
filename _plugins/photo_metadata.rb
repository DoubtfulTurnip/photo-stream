module Jekyll
  module PhotoMetadata
    module Lookup
      module_function

      def metadata_for(site, photo)
        return photo if photo.is_a?(Hash)

        photos = site.data.fetch("photos", {}) || {}
        photos.fetch(photo.name, {}) || {}
      end

      def hidden?(site, photo)
        PhotoIndex.truthy?(metadata_for(site, photo)["hidden"])
      end
    end

    module Filters
      def visible_photos(photos)
        site = @context.registers[:site]
        photos.reject { |photo| Lookup.hidden?(site, photo) }
      end

      def photo_metadata(photo)
        site = @context.registers[:site]
        Lookup.metadata_for(site, photo)
      end

      def photo_title(photo)
        metadata = photo_metadata(photo)
        title = metadata["title"].to_s.strip
        return title unless title.empty?

        name = metadata["name"] || photo.name
        File.basename(name, ".*")
      end

      def photo_caption(photo)
        photo_metadata(photo)["caption"].to_s.strip
      end

      def photo_location(photo)
        photo_metadata(photo)["location"].to_s.strip
      end

      def photo_tags(photo)
        tags = photo_metadata(photo)["tags"]
        return [] if tags.nil?

        Array(tags).map { |tag| tag.to_s.strip }.reject(&:empty?)
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::PhotoMetadata::Filters)
