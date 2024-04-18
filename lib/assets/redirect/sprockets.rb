require "rack"
require "rack/request"
require "rack/mime"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/object/try"

class Assets::Redirect::Sprockets
  # TODO comment
  def initialize(app, environment, prefix: "/assets", asset_host: nil, public_path: "/public")
    @app = app
    @environment = environment
    @prefix = prefix
    @asset_host = asset_host
    @public_path = public_path
  end

  def call(env)
    @request = Rack::Request.new(env)

    if asset_not_found? && redirect_path_match?
      redirect_to_current_version(env)
    else
      @app.call(env)
    end
  end

  private
    def asset_not_found?
      @request.path.start_with?(@prefix) && !file_exists?(@request.path.chomp("/"))
    end

    def redirect_path_match?
      file_exists?(redirect_path)
    end

    def file_exists?(asset_path)
      File.exists?(File.join(@public_path, asset_path))
    end

    def redirect_path
      "#{@prefix}/#{@environment[ logical_path ]&.digest_path}"
    end

    def logical_path
      @request.path.sub(/^#{@prefix}\//, "").sub(/-[a-z0-9]{32}(?<=.)/i, "")
    end

    def redirect_to_current_version(env)
      url = URI(computed_asset_host || @request.url)
      url.path = redirect_path

      headers = { "Location"      => url.to_s,
                  "Content-Type"  => Rack::Mime.mime_type(::File.extname(digest_path)),
                  "Pragma"        => "no-cache",
                  "Cache-Control" => "no-cache; max-age=0" }

      [ 302, headers, [ redirect_message(url.to_s) ] ]
    end

    def computed_asset_host
      if @asset_host.respond_to?(:call)
        host = @asset_host.call(@request)
      else
        host = @asset_host
      end

      # TODO refactor
      if host.nil? || host =~ %r(^https?://)
        host
      else
        "#{@request.scheme}://#{host}"
      end
    end

    def redirect_message(location)
      %[Redirecting to <a href="#{location}">#{location}</a>]
    end
end
