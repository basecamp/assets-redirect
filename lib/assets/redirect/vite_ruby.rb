require_relative "base"

class Assets::Redirect::ViteRuby < Assets::Redirect::Base
  private
    def path_from_manifest
      # ViteRuby include /vite/assets to the resolved logical_path
      strip_assets_prefix ViteRuby.instance.manifest.path_for(manifest_logical_path)
    rescue ViteRuby::MissingEntrypointError
      nil
    end

    def manifest_logical_path
      # ViteRuby manifest uses source extensions (.ts) but browsers request .js
      logical_path.sub(/\.js$/, ".ts")
    end

    FINGERPRINT_REGEXP = /
      -                              # Hyphen
      [0-9a-zA-Z_-]{3,}               # Rollup or Propshaft digest
      .                              # Dot
      /x

    def logical_path
      strip_assets_prefix(@request.path).sub(FINGERPRINT_REGEXP, ".")
    end
end