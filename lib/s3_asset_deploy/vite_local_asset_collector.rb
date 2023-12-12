class ViteLocalAssetCollector < S3AssetDeploy::RailsLocalAssetCollector
    def initialize(remove_fingerprint: nil, vite_hash_prefix: nil, vite_dynamic_flag: nil)
        super
        remove_fingerprint = ->(path) { self.remove_fingerprint(path) } if remove_fingerprint.nil?
        @remove_fingerprint = remove_fingerprint
        @vite_hash_prefix = vite_hash_prefix
        @vite_dynamic_flag = vite_dynamic_flag

        raise "Vite hash prefix is required" unless @vite_hash_prefix
        raise "Vite dynamic flag is required" unless @vite_dynamic_flag
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

    def remove_fingerprint(path)
        S3AssetDeploy::AssetHelper.remove_fingerprint_vite(path, @vite_hash_prefix, @vite_dynamic_flag)
    end
end