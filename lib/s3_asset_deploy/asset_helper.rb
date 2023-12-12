# frozen_string_literal: true

require "mime/types"

class S3AssetDeploy::AssetHelper
  FINGERPRINTED_ASSET_REGEX = /\A(.*)-([[:alnum:]]+)((?:(?:\.[[:alnum:]]+))+)\z/.freeze

  def self.remove_fingerprint(path)
    match_data = path.match(FINGERPRINTED_ASSET_REGEX)
    return path unless match_data
    "#{match_data[1]}#{match_data[3]}"
  end

  def self.mime_type_for_path(path)
    extension = File.extname(path)[1..-1]
    return "application/json" if extension == "map"
    MIME::Types.type_for(extension).first
  end

  # Vite hashes should be configured to start with the
  # vite_hash_prefix (e.g. -vtash). Return the filename without the
  # hash, but keep the extension.
  #
  # Turn assets/uppy-vthash0opbZYF5.css into assets/uppy-vite.css
  #
  # We add -vite because some assets may be managed by both Sprockets
  # and Vite.
  # If the asset is marked as dynamic with the vite_dynamic_flag (e.g.
  # -vtdynamic), then we don't remove the hash.
  def remove_fingerprint_vite(path, vite_hash_prefix, vite_dynamic_flag)
      if path.include?(vite_dynamic_flag)
          return path
      elsif path.include?(vite_hash_prefix)
          *prefix, extension = path.split(".")
          filename = prefix.join(".")
          return filename.gsub(/#{vite_hash_prefix}.*/,'-vite') + "." + extension
      else
          self.remove_fingerprint(path)
      end
  end
end
