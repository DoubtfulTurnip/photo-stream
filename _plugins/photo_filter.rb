require "exiftool"

module Jekyll
  module PhotoFilter
    IMAGE_EXTENSIONS = %w[.gif .jpeg .jpg .png .webp].freeze

    def photo_filter(files)
      photos = files.select { |photo| photo_file?(photo) }
      sorted = photos.sort_by { |photo|
        begin
          exif = Exiftool.new(photo.path)
          exif[:date_time_original] || photo.modified_time
        rescue StandardError
          photo.modified_time
        end
      }
      sorted.reverse
    end

    private

    def photo_file?(file)
      relative_path = file.relative_path.tr("\\", "/").delete_prefix("./").delete_prefix("/")

      relative_path.start_with?("photos/original/") &&
        IMAGE_EXTENSIONS.include?(File.extname(relative_path).downcase)
    end
  end
end
Liquid::Template.register_filter(Jekyll::PhotoFilter)
