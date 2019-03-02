require 'sprockets/bumble_d/config'
require 'sprockets/bumble_d/transformer'

module Sprockets
  module BumbleD
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        config.sprockets_bumble_d = Config.new
        config.sprockets_bumble_d.root_dir = ::Rails.root.to_s
      end

      initializer 'sprockets-bumble_d.configure_transformer' do |app|
        bumble_d_config = app.config.sprockets_bumble_d
        root_dir = bumble_d_config.root_dir
        babel_config_version = bumble_d_config.babel_config_version
        babel_plugins = bumble_d_config.babel_options[:plugins]

        if bumble_d_config.transform_to_umd
          babel_plugins += [
            ['@babel/plugin-transform-modules-umd', {
              exactGlobals: true,
              globals: bumble_d_config.globals_map
            }]
          ]
        end

        options = bumble_d_config.babel_options.merge(
          plugins: babel_plugins,
          root_dir: root_dir,
          babel_config_version: babel_config_version
        )
        babel_transformer = Transformer.new(options)

        # Using the deprecated register_engine rather than register_mime_type
        # and register_transformer because otherwise .es6 files that aren't
        # in the precompile list will get unnecessarily compiled. See
        # https://github.com/rails/sprockets/issues/384
        Sprockets.register_engine(
          bumble_d_config.file_extension,
          babel_transformer,
          mime_type: 'application/javascript',
          silence_deprecation: true
        )
      end
    end
  end
end
