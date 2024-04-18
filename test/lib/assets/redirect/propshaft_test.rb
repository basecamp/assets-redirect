require "test_helper"

class Assets::Redirect::PropshaftTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  setup { @app = build_app }
  attr_accessor :app

  SNOWGLOBE_DIGEST = "391dafc3c8e0f58faf6677e72efb27c1"

  def build_app(options = {})
    default_app = lambda do |env|
      headers = {"Content-Type" => "text/html"}
      [ 200, headers, [ "OK" ] ]
    end
    resolver = mock("object")
    resolver.stubs(:resolve).with("snowglobe.png").returns("/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png")
    resolver.stubs(:resolve).with("unmatched.png").returns(nil)
    resolver.stubs(:resolve).with("deleted-snowglobe.png").returns("/assets/deleted-snowglobe-#{SNOWGLOBE_DIGEST}.png")
    propshaft = stub(resolver: resolver)
    Assets::Redirect::Propshaft.new(default_app, propshaft, **{ public_path: "test/fixtures" }.merge(options))
  end

  def test_redirect
    get "http://example.org/assets/snowglobe-8f05909c25ad578ba8fbb27fb28da779.png"
    assert_equal "http://example.org/assets/snowglobe-#{SNOWGLOBE_DIGEST}.png",
      last_response.headers["Location"]

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
end
