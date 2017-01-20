module Sprockets
  module BumbleD
    class Resolver
      def initialize(babel)
        @babel = babel
      end

      def resolve_plugins(plugins)
        resolve_them(plugins, type: 'Plugin')
      end

      def resolve_presets(presets)
        resolve_them(presets, type: 'Preset')
      end

      private

      def resolve_them(plugins_or_presets, type:)
        plugins_or_presets.map do |item|
          if item.is_a?(Array)
            [@babel.send("resolve#{type}", item[0]), item[1]]
          else
            @babel.send("resolve#{type}", item)
          end
        end
      end
    end
  end
end
