require "exiftool"
require "fileutils"
require "json"
require "time"

module Jekyll
  module PhotoIndex
    IMAGE_EXTENSIONS = %w[.gif .jpeg .jpg .png .webp].freeze

    module_function

    def photos(site)
      site.data["photo_stream"] ||= {}
      site.data["photo_stream"]["photos"] ||= build(site)
    end

    def visible_photos(site)
      photos(site).reject { |photo| truthy?(photo["hidden"]) }
    end

    def photo_file?(file)
      relative_path = normalize_path(file.relative_path)

      relative_path.start_with?("photos/original/") &&
        IMAGE_EXTENSIONS.include?(File.extname(relative_path).downcase)
    end

    def build(site)
      load_exif_cache(site)
      photo_stream_data(site)["exif_cache_seen"] = {}

      photos = site.static_files
        .select { |file| photo_file?(file) }
        .map { |file| photo_hash(site, file) }
        .sort_by { |photo| photo["sort_time"] }
        .reverse

      write_exif_cache(site)
      photos
    end

    def photo_hash(site, file)
      metadata = metadata_for(site, file.name)
      exif = exif_for(site, file)
      taken_at = parse_time(exif[:date_time_original])
      modified_time = file.modified_time
      basename = File.basename(file.name, ".*")

      {
        "name" => file.name,
        "path" => file.path,
        "relative_path" => normalize_path(file.relative_path),
        "modified_time" => modified_time,
        "sort_time" => taken_at || modified_time,
        "slug" => Utils.slugify(basename),
        "title" => metadata.fetch("title", "").to_s.strip,
        "caption" => metadata.fetch("caption", "").to_s.strip,
        "location" => metadata.fetch("location", "").to_s.strip,
        "tags" => Array(metadata["tags"]).map { |tag| tag.to_s.strip }.reject(&:empty?),
        "hidden" => metadata["hidden"],
        "height" => exif[:height],
        "width" => exif[:width]
      }
    end

    def metadata_for(site, name)
      photos = site.data.fetch("photos", {}) || {}
      photos.fetch(name, {}) || {}
    end

    def exif_for(site, file)
      relative_path = normalize_path(file.relative_path)
      photo_stream_data(site)["exif_cache_seen"][relative_path] = true
      cache = exif_cache(site)
      entry = cache[relative_path]
      mtime = File.mtime(file.path).to_i
      size = File.size(file.path)

      if entry && entry["mtime"] == mtime && entry["size"] == size
        return symbolize_keys(entry.fetch("exif", {}))
      end

      exif = read_exif(file.path)
      cache[relative_path] = {
        "mtime" => mtime,
        "size" => size,
        "exif" => {
          "date_time_original" => exif[:date_time_original]&.to_s,
          "height" => exif[:height],
          "width" => exif[:width]
        }
      }
      exif_cache_dirty(site)

      exif
    end

    def read_exif(path)
      return {} unless File.exist?(path)

      Exiftool.new(path).to_hash
    rescue StandardError => e
      Jekyll.logger.warn "Photo Stream:", "Could not read EXIF for #{path}: #{e.message}"
      {}
    end

    def parse_time(value)
      return value if value.is_a?(Time)
      return nil if value.nil?

      Time.parse(value.to_s.tr(":", "-", 2))
    rescue ArgumentError
      nil
    end

    def normalize_path(path)
      path.to_s.tr("\\", "/").delete_prefix("./").delete_prefix("/")
    end

    def truthy?(value)
      value == true || value.to_s == "true" || value.to_s == "1"
    end

    def load_exif_cache(site)
      photo_stream_data(site)["exif_cache"] ||= begin
        path = exif_cache_path(site)
        if File.exist?(path)
          JSON.parse(File.read(path))
        else
          {}
        end
      rescue StandardError => e
        Jekyll.logger.warn "Photo Stream:", "Could not read EXIF cache: #{e.message}"
        {}
      end
    end

    def write_exif_cache(site)
      seen = photo_stream_data(site)["exif_cache_seen"]
      if seen && exif_cache(site).keys.any? { |path| !seen[path] }
        exif_cache(site).select! { |path, _entry| seen[path] }
        exif_cache_dirty(site)
      end

      return unless photo_stream_data(site)["exif_cache_dirty"]

      path = exif_cache_path(site)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate(exif_cache(site)))
    rescue StandardError => e
      Jekyll.logger.warn "Photo Stream:", "Could not write EXIF cache: #{e.message}"
    end

    def exif_cache(site)
      photo_stream_data(site)["exif_cache"] || load_exif_cache(site)
    end

    def exif_cache_dirty(site)
      photo_stream_data(site)["exif_cache_dirty"] = true
    end

    def exif_cache_path(site)
      status_dir = ENV["PHOTO_STREAM_STATUS_DIR"] || File.join(site.source, ".photo-stream")
      ENV["PHOTO_STREAM_PHOTO_INDEX_CACHE"] || File.join(status_dir, "photo-index.json")
    end

    def photo_stream_data(site)
      site.data["photo_stream"] ||= {}
    end

    def symbolize_keys(hash)
      hash.each_with_object({}) { |(key, value), result| result[key.to_sym] = value }
    end
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  site.data.delete("photo_stream") if site.data
end
