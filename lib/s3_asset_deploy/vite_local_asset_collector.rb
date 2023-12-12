class ViteLocalAssetCollector < S3AssetDeploy::RailsLocalAssetCollector
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
end