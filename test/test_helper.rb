$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "assets/redirect"
require "minitest/autorun"
require "rack/test"
require "mocha/minitest"
require "active_support/all"

ActiveSupport.test_order = :random
