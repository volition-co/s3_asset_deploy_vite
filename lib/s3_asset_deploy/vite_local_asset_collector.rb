class S3AssetDeploy::ViteLocalAssetCollector < S3AssetDeploy::RailsLocalAssetCollector
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

                # Get CSS chunks
                if asset["css"] && asset["css"].is_a?(Array)
                    asset["css"].each do |css|
                        vite_paths << css["file"]
                    end
                end

                # Get source maps
                if asset["file"].end_with?(".js")
                    map_file = asset["file"].gsub(/\.js$/, ".map")
                    vite_paths << map_file if File.exist?(public_path.join("assets", map_file))
                end
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