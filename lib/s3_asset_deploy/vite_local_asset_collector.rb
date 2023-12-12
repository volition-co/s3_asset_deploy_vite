class ViteLocalAssetCollector < S3AssetDeploy::RailsLocalAssetCollector
    def initialize(remove_fingerprint: nil, vite_hash_prefix: '-vthash', vite_dynamic_flag: '-vtdynamic')
        super
        remove_fingerprint = ->(path) { self.remove_fingerprint(path) } if remove_fingerprint.nil?
        @remove_fingerprint = remove_fingerprint
        @vite_hash_prefix = vite_hash_prefix
        @vite_dynamic_flag = vite_dynamic_flag
    end

    def assets
      super + assets_from_vite
    end

    def assets_from_vite
        vite_paths = []
        manifest_file = public_path.join(".vite", "manifest.json")
        manifest_assets_file = public_path.join(".vite", "manifest-assets.json")

        if manifest_file.exist?
            manifest = JSON.parse(File.open(manifest_file).read)
            manifest.each do |_, asset|
                vite_paths << asset["file"]
            end
        end

        if manifest_assets_file.exist?
            manifest = JSON.parse(File.open(manifest_assets_file).read)
            manifest.each do |_, asset|
                vite_paths << asset["file"]
            end
        end

        vite_paths.uniq.map{ |path| S3AssetDeploy::RailsLocalAsset.new(path, remove_fingerprint: @remove_fingerprint) }
    end

    # Vite hashes should be configured to start with the
    # vite_hash_prefix (e.g. -vtash). Return the filename without the
    # hash, but keep the extension.
    #
    # Turn assets/uppy-vthash0opbZYF5.css into assets/uppy-vite.css 
    
    # We add -vite because some assets may be managed by both Sprockets
    # and Vite.
    # If the asset is marked as dynamic with the vite_dynamic_flag (e.g.
    # -vtdynamic), then we don't remove the hash.
    def remove_fingerprint(path)
        if path.include?(@vite_dynamic_flag)
            return path
        elsif path.include?(@vite_hash_prefix)
            *prefix, extension = path.split(".")
            filename = prefix.join(".")
            return filename.gsub(/#{@vite_hash_prefix}.*/,'-vite') + "." + extension
        else
            S3AssetDeploy::AssetHelper.remove_fingerprint(path)
        end
    end
end