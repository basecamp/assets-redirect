require "rack"
require "rack/request"
require "rack/mime"

class Assets::Redirect::Base
  def initialize(app, assets_pipeline, public_path: "/public", assets_prefix: "/assets", logger: nil)
    @app = app
    @assets_pipeline = assets_pipeline
    @public_path = public_path
    @assets_prefix = assets_prefix
    @logger = logger
  end

  def call(env)
    @request = Rack::Request.new(env)

    if should_redirect?
      redirect_to_resolved_version_from_manifest
    else
      @app.call(env)
    end
  end

  private
    def should_redirect?
      Assets::Redirect.enabled && asset_not_found? && file_exists?(redirect_path)
    end

    def asset_not_found?
      @request.path.start_with?(@assets_prefix) && !file_exists?(@request.path)
    end

    def file_exists?(path)
      full_path = File.join(@public_path, path)
      File.exist?(full_path) && !File.directory?(full_path)
    end

    def redirect_path
      "#{@assets_prefix}/#{path_from_manifest}"
    end

    def path_from_manifest
      raise NotImplementedError, "ovverride in subclasses"
    end

    def computed_assets_pipeline
      @computed_assets_pipeline ||= @assets_pipeline.respond_to?(:call) ? @assets_pipeline.call : @assets_pipeline
    end

    def logical_path
      strip_assets_prefix(@request.path).sub(/-[a-z0-9]{7,128}\./i, ".")
    end

    def strip_assets_prefix(path)
      path&.sub(/\/?^#{@assets_prefix}\//, "")
    end

    def redirect_to_resolved_version_from_manifest
      url = URI(@request.url)
      url.path = redirect_path

      headers = { "Location"      => url.to_s,
                  "Content-Type"  => Rack::Mime.mime_type(File.extname(path_from_manifest)),
                  "Cache-Control" => "no-cache; max-age=0" }

      log "assets-redirect: Redirecting to #{redirect_path}"
      [ 302, headers, [ redirect_message(url) ] ]
    end

    def redirect_message(location)
      %[Redirecting to <a href="#{location}">#{location}</a>]
    end

    def log(msg)
      @logger&.info(msg)
    end
end
