require "exiftool"
require "time"

module Jekyll
  module PhotoFilter
    IMAGE_EXTENSIONS = %w[.gif .jpeg .jpg .png .webp].freeze

    def photo_filter(files)
      photos = files.select { |photo| photo_file?(photo) }
      sorted = photos.sort_by { |photo|
        photo_time(photo)
      }
      sorted.reverse
    end

    private

    def photo_time(photo)
      photo_time_cache[cache_key(photo)] ||= begin
        exif = Exiftool.new(photo.path)
        parse_time(exif[:date_time_original]) || photo.modified_time
      end
    rescue StandardError
      photo.modified_time
    end

    def photo_time_cache
      @photo_time_cache ||= {}
    end

    def cache_key(photo)
      [photo.path, photo.modified_time.to_i]
    end

    def parse_time(value)
      return value if value.is_a?(Time)
      return nil if value.nil?

      Time.parse(value.to_s.tr(":", "-", 2))
    rescue ArgumentError
      nil
    end

    def photo_file?(file)
      relative_path = file.relative_path.tr("\\", "/").delete_prefix("./").delete_prefix("/")

      relative_path.start_with?("photos/original/") &&
        IMAGE_EXTENSIONS.include?(File.extname(relative_path).downcase)
    end
  end
end
Liquid::Template.register_filter(Jekyll::PhotoFilter)
