require 'sprockets/bumble_d/config'
require 'sprockets/bumble_d/transformer'

module Sprockets
  module BumbleD
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        config.sprockets_bumble_d = Config.new
      end

      initializer 'sprockets-bumble_d.configure_transformer' do |app|
        bumble_d_config = app.config.sprockets_bumble_d
        root_dir = bumble_d_config.root_dir
        babel_config_version = bumble_d_config.babel_config_version
        babel_plugins = bumble_d_config.babel_options[:plugins]

        options = bumble_d_config.babel_options.merge(
          plugins: babel_plugins + [
            ['transform-es2015-modules-umd', {
              exactGlobals: true,
              globals: bumble_d_config.globals_map
            }]
          ],
          root_dir: root_dir,
          babel_config_version: babel_config_version
        )
        es6_transformer = Transformer.new(options)

        # Using the deprecated register_engine rather than register_mime_type
        # and register_transformer because otherwise .es6 files that aren't
        # in the precompile list will get unnecessarily compiled. See
        # https://github.com/rails/sprockets/issues/384
        Sprockets.register_engine(
          '.es6',
          es6_transformer,
          mime_type: 'application/javascript',
          silence_deprecation: true
        )
      end
    end
  end
end
