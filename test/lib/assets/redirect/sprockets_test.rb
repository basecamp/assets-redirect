require "test_helper"

class Assets::Redirect::SprocketsTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  setup { @app = build_app }
  attr_accessor :app

  SNOWGLOBE_DIGEST = "391dafc3c8e0f58faf6677e72efb27c1"

  def build_app(options = {})
    default_app = lambda do |env|
      headers = {"Content-Type" => "text/html"}
      [ 200, headers, [ "OK" ] ]
    end
    sprockets = { "snowglobe.png" => stub(digest_path: "snowglobe-#{SNOWGLOBE_DIGEST}.png") }
    Assets::Redirect::Sprockets.new(default_app, sprockets, **{ public_path: "test/fixtures" }.merge(options))
  end

  def test_redirect
    get "http://example.org/assets/snowglobe-8f05909c25ad578ba8fbb27fb28da779.png"
    assert_equal "http://example.org/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png",
      last_response.headers["Location"]
    assert_equal "image/png", last_response.header["Content-Type"]
    assert_equal "no-cache; max-age=0", last_response.headers["Cache-control"]
    assert_equal 302, last_response.status
    assert_match /Redirecting to.*example\.org/, last_response.body

    get "http://example.org/assets/snowglobe.png"
    assert_equal "http://example.org/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png",
      last_response.headers["Location"]
  end

  def test_no_redirect
    get "http://example.org/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png"
    assert_equal 200, last_response.status

    get "http://example.org/users"
    assert_equal 200, last_response.status

    get "http://example.org/assets/unmatched-#{SNOWGLOBE_DIGEST}.png"
    assert_equal 200, last_response.status

    get "http://example.org/assets/deleted-snowglobe-391dafc3c840f58faf6677e72efb27c1.png"
    assert_equal 200, last_response.status

    Assets::Redirect.enabled = false
    get "http://example.org/assets/snowglobe-391dafc3c840f58faf6677e72efb27c1.png"
    assert_equal 200, last_response.status
    Assets::Redirect.enabled = true
  end

  def test_custom_public_path
    self.app = build_app(public_path: "test/fixtures/assets", assets_prefix: "")

    get "http://example.org/snowglobe-399dafc3c8e0f58faf6677e72efb27c1.png"
    assert_equal "http://example.org/snowglobe-#{SNOWGLOBE_DIGEST}.png",
      last_response.headers["Location"]

    get "http://example.org/snowglobe-#{SNOWGLOBE_DIGEST}.png"
    assert_equal 200, last_response.status
  end

  def test_custom_assets_prefix
    self.app = build_app(assets_prefix: "/hidden-assets")

    get "http://example.org/hidden-assets/snowglobe-399dafc3c8e0f58faf6677e72efb27c1.png"
    assert_equal "http://example.org/hidden-assets/snowglobe-#{SNOWGLOBE_DIGEST}.png",
      last_response.headers["Location"]

    get "http://example.org/assets/snowglobe-399dafc3c8e0f58faf6677e72efb27c1.png"
    assert_equal 200, last_response.status
  end
end
