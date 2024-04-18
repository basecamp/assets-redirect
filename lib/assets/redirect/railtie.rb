if defined?(Rails)
  class Assets::Redirect::Railtie < ::Rails::Railtie
    initializer "insert_assets_redirect_middleware" do |app|
      if !app.config.assets.compile && app.config.assets.digest
        middleware_class = \
          if defined?(Sprockets::Base)
            Assets::Redirect::Sprockets
          elsif defined?(Propshaft)
            Assets::Redirect::Propshaft
          else
            raise "assets-redirect: Only Sprockets and Propshaft are supported."
          end

        app.middleware.insert 0,
          middleware_class,
          -> { Rails.application.assets },
          public_path: app.config.paths["public"].first,
          assets_prefix: app.config.assets.prefix,
          logger: Rails.logger
      end
    end
  end
end
