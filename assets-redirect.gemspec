require_relative "lib/assets/redirect/version"

Gem::Specification.new do |spec|
  spec.name = "assets-redirect"
  spec.version = Assets::Redirect::VERSION
  spec.authors = ["Jacopo"]
  spec.email = ["jacopo@37signals.com"]

  spec.summary = "Redirect not found assets to their latest digested version."
  spec.description = <<-EOS
    Rack middleware which will look up your assets manifest file and redirect a
    404 assets request to the current digested version of the asset.
  EOS

  spec.homepage = "https://github.com/basecamp/assets_redirect"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.8"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = %Q(#{spec.metadata["source_code_uri"]}/CHANGELOG.md)

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ .git .github Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency "activesupport", ">= 4.2.0"
end
