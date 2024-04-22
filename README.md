# Assets::Redirect

A Rack middleware for [Rails](https://github.com/rails/rails) with asset pipeline and asset digest enabled. This middleware is used to redirect any not found request to static asset to the latest version with digest in its filename by reading the  manifest file generated after you run `rake assets:precompile`

For example, if a browser is requesting this URL, and the image with the digest has been removed:

    http://example.org/assets/dog-faa42cf2fd5db7e7290baa07109bc82b.png

They will get redirected to the current version pointed by the manifest:

    http://example.org/assets/application-faa42cf2fd5db7e7290baa07109bc99b.png

This gem is designed to run on your staging or production environment, where you already precompile all your assets, turn on your asset digest, and turn of asset compilation. This is useful if you're having a static page or email which refers to static assets in the asset pipeline, in this case the asset with the old digest can be lost after a deploymeny, and is convenient to automatically show the current version instead of a 404.

This gem has been inspired from https://github.com/sikachu/sprockets-redirect, but with the difference that in this gem both digested/undigested links will automatically redirect to the latest digested version.

## Requirements

- Application running on [Ruby on Rails](http://github.com/rails/rails) version >= 4.2.0.
- [Sprockets](https://github.com/rails/sprockets) or [Propshaft](https://github.com/rails/propshaft) as assets pipeline.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add assets-redirect

## Usage

This middleware will be enabled by default if you set `config.assets.compile = false` and `config.assets.digest = true` in your configuration file.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/basecamp/assets-redirect.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
