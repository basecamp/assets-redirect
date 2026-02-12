require_relative "base"

class Assets::Redirect::ViteRuby < Assets::Redirect::Base
  private
    FINGERPRINT_REGEXP = /
      -                    # Hyphen separator
      [0-9a-zA-Z_-]{3,}   # Rollup content hash
      \.                   # Literal dot
    /x

    def path_from_manifest
      logical = logical_path
      base = File.basename(logical, File.extname(logical))
      ext = File.extname(logical)

      reverse_lookup_manifest(base, ext)
    end

    def logical_path
      strip_assets_prefix(@request.path).sub(FINGERPRINT_REGEXP, ".")
    end

    def reverse_lookup_manifest(base, ext)
      vite_manifest.each_value do |entry|
        file = entry["file"]
        return strip_assets_prefix(file) if output_matches?(file, base, ext)

        entry["css"]&.each do |css_file|
          return strip_assets_prefix(css_file) if output_matches?(css_file, base, ext)
        end
      end

      nil
    end

    def output_matches?(output_path, base, ext)
      return false unless output_path
      name = File.basename(output_path)
      name.start_with?("#{base}-") && name.end_with?(ext)
    end

    def vite_manifest
      ViteRuby.instance.manifest.send(:manifest)
    end
end
