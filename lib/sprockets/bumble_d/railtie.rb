require 'sprockets/bumble_d/config'
require 'sprockets/bumble_d/transformer'
require 'sprockets/directive_processor'

module Sprockets
  module BumbleD
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        config.sprockets_bumble_d = Config.new
      end

      # rubocop:disable Metrics/BlockLength
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

        Sprockets.register_mime_type(
          'application/ecmascript-6',
          extensions: ['.es6'],
          charset: :unicode
        )
        Sprockets.register_transformer(
          'application/ecmascript-6',
          'application/javascript',
          es6_transformer
        )
        Sprockets.register_preprocessor(
          'application/ecmascript-6',
          DirectiveProcessor.new(comments: ['//', ['/*', '*/']])
        )
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
