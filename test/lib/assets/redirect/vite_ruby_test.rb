require "test_helper"

class Assets::Redirect::ViteRubyTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  setup { @app = build_app }
  attr_accessor :app

  SNOWGLOBE_DIGEST = "391dafc3c8e0f58faf6677e72efb27c1"

  def build_app(options = {})
    default_app = lambda do |env|
      headers = {"Content-Type" => "text/html"}
      [ 200, headers, [ "OK" ] ]
    end

    manifest = mock("manifest")
    manifest.stubs(:path_for).with("snowglobe.png").returns("/vite/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png")
    manifest.stubs(:path_for).with("unmatched.png").raises(ViteRuby::MissingEntrypointError.new("unmatched.png"))
    manifest.stubs(:path_for).with("deleted-snowglobe.png").returns("/vite/assets/deleted-snowglobe-#{SNOWGLOBE_DIGEST}.png")

    vite_instance = stub(manifest: manifest)
    ViteRuby.stubs(:instance).returns(vite_instance)

    Assets::Redirect::ViteRuby.new(default_app, nil, **{ public_path: "test/fixtures", assets_prefix: "/vite/assets" }.merge(options))
  end

  def test_redirect
    get "http://example.org/vite/assets/snowglobe-8f05909c25ad578ba8fbb27fb28da779.png"
    assert_equal "http://example.org/vite/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png",
      last_response.headers["Location"]

    get "http://example.org/vite/assets/snowglobe.png"
    assert_equal "http://example.org/vite/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png",
      last_response.headers["Location"]
  end

  def test_no_redirect
    get "http://example.org/vite/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png"
    assert_equal 200, last_response.status

    get "http://example.org/users"
    assert_equal 200, last_response.status

    get "http://example.org/vite/assets/unmatched-#{SNOWGLOBE_DIGEST}.png"
    assert_equal 200, last_response.status

    get "http://example.org/vite/assets/deleted-snowglobe-391dafc3c840f58faf6677e72efb27c1.png"
    assert_equal 200, last_response.status

    Assets::Redirect.enabled = false
    get "http://example.org/vite/assets/snowglobe-391dafc3c840f58faf6677e72efb27c1.png"
    assert_equal 200, last_response.status
    Assets::Redirect.enabled = true
  end
end

module ViteRuby
  class MissingEntrypointError < StandardError; end
end
