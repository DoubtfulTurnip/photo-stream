require "exiftool"

module Jekyll
  module PhotoFilter
    def photo_filter(files)
      photos = files.select {|photo| photo.relative_path.include?("original") }
      sorted = photos.sort_by { |photo|
        exif = Exiftool.new(photo.path)
        exif[:date_time_original] || photo.modified_time.to_s
      }
      sorted.reverse
    end
  end
end
Liquid::Template.register_filter(Jekyll::PhotoFilter)
