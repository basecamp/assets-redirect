require_relative "redirect/version"
require_relative "redirect/sprockets"
require_relative "redirect/propshaft"
require_relative "redirect/railtie"

module Assets::Redirect
  @enabled = true
  class << self; attr_accessor :enabled end
end
