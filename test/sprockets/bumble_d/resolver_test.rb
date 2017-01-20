require 'test_helper'

require 'sprockets/bumble_d/resolver'
require 'sprockets/bumble_d/transformer'

module Sprockets
  module BumbleD
    class ResolverTest < Minitest::Test
      def test_resolve_plugins
        node_modules_path = `cd #{File.expand_path(__dir__)} && npm root`[0...-1]
        resolver = new_resolver
        resolved_external_helpers_plugin = File.join(node_modules_path, 'babel-plugin-external-helpers/lib/index.js')
        resolved_umd_plugin = File.join(node_modules_path, 'babel-plugin-transform-es2015-modules-umd/lib/index.js')

        assert_equal [], resolver.resolve_plugins([])

        assert_equal [resolved_external_helpers_plugin], resolver.resolve_plugins(['external-helpers'])

        assert_equal [resolved_external_helpers_plugin, resolved_umd_plugin],
                     resolver.resolve_plugins(['external-helpers', 'transform-es2015-modules-umd'])

        assert_equal [[resolved_umd_plugin, { exactGlobals: true }]],
                     resolver.resolve_plugins([['transform-es2015-modules-umd', { exactGlobals: true }]])

        plugins = ['external-helpers', ['transform-es2015-modules-umd', { exactGlobals: true }]]
        assert_equal [resolved_external_helpers_plugin, [resolved_umd_plugin, { exactGlobals: true }]],
                     resolver.resolve_plugins(plugins)
      end

      def test_resolve_presets
        node_modules_path = `cd #{File.expand_path(__dir__)} && npm root`[0...-1]
        resolver = new_resolver
        resolved_es2015_preset = File.join(node_modules_path, 'babel-preset-es2015/lib/index.js')

        assert_equal [], resolver.resolve_presets([])

        assert_equal [resolved_es2015_preset], resolver.resolve_presets(['es2015'])

        assert_equal [[resolved_es2015_preset, { modules: false }]],
                     resolver.resolve_presets([['es2015', { modules: false }]])

        assert_equal [resolved_es2015_preset, [resolved_es2015_preset, { modules: false }]],
                     resolver.resolve_presets(['es2015', ['es2015', { modules: false }]])
      end

      private

      def new_resolver
        Resolver.new(Transformer::BabelBridge.new(File.expand_path(__dir__)))
      end
    end
  end
end
