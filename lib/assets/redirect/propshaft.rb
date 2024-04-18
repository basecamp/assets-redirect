require_relative "base"

class Assets::Redirect::Propshaft < Assets::Redirect::Base
  private
    def path_from_manifest
      # Propshaft include /assets to the resolved logical_path
      strip_assets_prefix computed_assets_pipeline.resolver.resolve(logical_path)
    end
end
