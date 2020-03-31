module RedmineS3
  module ThumbnailPatch
    # Generates a thumbnail for the source image to target
    def self.generate_s3_thumb(source, target, size, update_thumb = false)
      target_folder = RedmineS3::Connection.thumb_folder
      if update_thumb
        return unless Object.const_defined?(:MiniMagick)
        url = RedmineS3::Connection.object_url(source)
        img = MiniMagick::Image.open(url)
        img.combine_options do |c|
          # convert everthing to jpg, compress files according to https://stackoverflow.com/a/48869031/156448
          if img.mime_type != "image/jpeg"
            img.format("jpg",1)
          end
          c.quality("60")
          c.interlace("plane")
          c.gaussian_blur("0.05")
          c.strip
          c.resize("#{size}x#{size}")
        end

        RedmineS3::Connection.put(target, File.basename(target), img.to_blob, img.mime_type, target_folder)
      end
      RedmineS3::Connection.object_url(target, target_folder)
    end
  end
end
