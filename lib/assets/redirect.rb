require_relative "redirect/version"
require_relative "redirect/sprockets"

module Assets::Redirect
  # TODO railtie for auto-install
  mattr_accessor :install
  self.install = true
end
