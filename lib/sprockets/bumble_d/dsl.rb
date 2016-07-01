module Sprockets
  module BumbleD
    module DSL
      def configure_sprockets_bumble_d(&block)
        initializer 'configure_sprockets_bumble_d',
                    before: 'sprockets-bumble_d.configure_transformer' do |app|
          app.config.sprockets_bumble_d.configure(&block)
        end
      end

      def register_umd_globals(module_name, globals_map)
        initializer "#{module_name}.register_umd_globals",
                    before: 'sprockets-bumble_d.configure_transformer' do |app|
          app.config.sprockets_bumble_d.register_globals(globals_map)
        end
      end
    end
  end
end
