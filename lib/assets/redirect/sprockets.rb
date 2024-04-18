require_relative "base"

class Assets::Redirect::Sprockets < Assets::Redirect::Base
  private
    def path_from_manifest
      computed_assets_pipeline[ logical_path ]&.digest_path
    end
end
