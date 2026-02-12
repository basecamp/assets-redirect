require "test_helper"

class Assets::Redirect::ViteRubyTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  setup { @app = build_app }
  attr_accessor :app

  JS_DIGEST = "C_-A_YA1"
  CSS_DIGEST = "BYuCEz6a"
  APP_JS_DIGEST = "DBfCPIOZ"

  def build_app(options = {})
    default_app = lambda do |env|
      headers = { "Content-Type" => "text/html" }
      [200, headers, ["OK"]]
    end

    manifest_hash = {
      "entrypoints/inertia.ts" => {
        "file" => "/vite/assets/inertia-#{JS_DIGEST}.js",
        "css" => ["/vite/assets/inertia-#{CSS_DIGEST}.css"],
        "isEntry" => true
      },
      "entrypoints/application.js" => {
        "file" => "/vite/assets/application-#{APP_JS_DIGEST}.js",
        "isEntry" => true
      }
    }

    manifest = mock("manifest")
    manifest.stubs(:manifest).returns(manifest_hash)

    vite_instance = stub(manifest: manifest)
    ViteRuby.stubs(:instance).returns(vite_instance)

    Assets::Redirect::ViteRuby.new(
      default_app, nil,
      public_path: "test/fixtures",
      assets_prefix: "/vite/assets",
      **options
    )
  end

  # --- Redirects ---

  def test_redirect_js_from_ts_source
    get "http://example.org/vite/assets/inertia-OLDHASH123.js"
    assert_equal 302, last_response.status
    assert_equal "http://example.org/vite/assets/inertia-#{JS_DIGEST}.js",
      last_response.headers["Location"]
  end

  def test_redirect_js_from_js_source
    get "http://example.org/vite/assets/application-OLDHASH123.js"
    assert_equal 302, last_response.status
    assert_equal "http://example.org/vite/assets/application-#{APP_JS_DIGEST}.js",
      last_response.headers["Location"]
  end

  def test_redirect_css_nested_under_parent_entry
    get "http://example.org/vite/assets/inertia-OLDHASH123.css"
    assert_equal 302, last_response.status
    assert_equal "http://example.org/vite/assets/inertia-#{CSS_DIGEST}.css",
      last_response.headers["Location"]
  end

  # --- No redirects ---

  def test_no_redirect_for_existing_file
    get "http://example.org/vite/assets/snowglobe-391dafc3c8e0f58faf6677e72efb27c1.png"
    assert_equal 200, last_response.status
  end

  def test_no_redirect_for_non_asset_path
    get "http://example.org/users"
    assert_equal 200, last_response.status
  end

  def test_no_redirect_for_unknown_asset
    get "http://example.org/vite/assets/nonexistent-OLDHASH123.js"
    assert_equal 200, last_response.status
  end

  def test_no_redirect_when_disabled
    Assets::Redirect.enabled = false
    get "http://example.org/vite/assets/inertia-OLDHASH123.js"
    assert_equal 200, last_response.status
  ensure
    Assets::Redirect.enabled = true
  end
end

module ViteRuby
  class MissingEntrypointError < StandardError; end
end
