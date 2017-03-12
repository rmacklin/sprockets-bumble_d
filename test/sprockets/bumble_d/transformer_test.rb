require 'test_helper'

require 'sprockets/cache'
require 'sprockets/bumble_d/resolver'
require 'sprockets/bumble_d/transformer'

module Sprockets
  module BumbleD
    class TransformerTest < Minitest::Test
      def test_it_compiles_es6_features_to_es5
        input = input_exemplar

        es6_transformer = new_transformer(presets: ['es2015'])

        expected = <<-JS.strip
"use strict";

var square = function square(n) {
  return n * n;
};
        JS

        assert_equal expected, es6_transformer.call(input)[:data]
      end

      def test_it_compiles_to_umd_modules
        es6_module = <<-JS.strip
import foo from 'foo/module';
import bar from 'bar/module';

export default 42;
        JS

        input = input_exemplar(
          data: es6_module,
          load_path: File.expand_path('../some/dir', __FILE__),
          filename: File.expand_path('../some/dir/mod.es6', __FILE__),
          name: 'some/dir/mod'
        )

        babel_options = {
          presets: ['es2015'],
          plugins: [
            'external-helpers',
            ['transform-es2015-modules-umd', {
              exactGlobals: true,
              globals: {
                'foo/module' => 'Foo',
                'bar/module' => 'BAR',
                'some/dir/mod' => 'Baz'
              }
            }]
          ]
        }

        es6_transformer = new_transformer(babel_options)

        expected = <<-JS.strip
(function (global, factory) {
  if (typeof define === "function" && define.amd) {
    define('some/dir/mod', ['exports', 'foo/module', 'bar/module'], factory);
  } else if (typeof exports !== "undefined") {
    factory(exports, require('foo/module'), require('bar/module'));
  } else {
    var mod = {
      exports: {}
    };
    factory(mod.exports, global.Foo, global.BAR);
    global.Baz = mod.exports;
  }
})(this, function (exports, _module, _module3) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });

  var _module2 = babelHelpers.interopRequireDefault(_module);

  var _module4 = babelHelpers.interopRequireDefault(_module3);

  exports.default = 42;
});
        JS

        assert_equal expected, es6_transformer.call(input)[:data]
      end

      def test_it_compiles_to_umd_modules__works_with_namespaces
        es6_module = <<-JS.strip
import Tooltip from 'foo/ui/tooltip/module';

export default 42;
        JS

        input = input_exemplar(
          data: es6_module,
          load_path: File.expand_path('../some/dir', __FILE__),
          filename: File.expand_path('../some/dir/mod.es6', __FILE__),
          name: 'some/dir/mod'
        )

        babel_options = {
          presets: ['es2015'],
          plugins: [
            'external-helpers',
            ['transform-es2015-modules-umd', {
              exactGlobals: true,
              globals: {
                'foo/ui/tooltip/module' => 'Foo.ui.Tooltip',
                'some/dir/mod' => 'Bar.ui.Modal'
              }
            }]
          ]
        }

        es6_transformer = new_transformer(babel_options)

        expected = <<-JS.strip
(function (global, factory) {
  if (typeof define === "function" && define.amd) {
    define('some/dir/mod', ['exports', 'foo/ui/tooltip/module'], factory);
  } else if (typeof exports !== "undefined") {
    factory(exports, require('foo/ui/tooltip/module'));
  } else {
    var mod = {
      exports: {}
    };
    factory(mod.exports, global.Foo.ui.Tooltip);
    global.Bar = global.Bar || {};
    global.Bar.ui = global.Bar.ui || {};
    global.Bar.ui.Modal = mod.exports;
  }
})(this, function (exports, _module) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });

  var _module2 = babelHelpers.interopRequireDefault(_module);

  exports.default = 42;
});
        JS

        assert_equal expected, es6_transformer.call(input)[:data]
      end

      def test_it_can_compile_to_another_module_format
        es6_module = <<-JS.strip
import foo from 'foo/module';
import bar from 'bar/module';

export default 42;
        JS

        input = input_exemplar(
          data: es6_module,
          load_path: File.expand_path('../some/dir', __FILE__),
          filename: File.expand_path('../some/dir/mod.es6', __FILE__),
          name: 'some/dir/mod'
        )

        babel_options = {
          presets: ['es2015'],
          plugins: [
            'external-helpers',
            'transform-es2015-modules-amd'
          ]
        }

        es6_transformer = new_transformer(babel_options)

        expected = <<-JS.strip
define('some/dir/mod', ['exports', 'foo/module', 'bar/module'], function (exports, _module, _module3) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });

  var _module2 = babelHelpers.interopRequireDefault(_module);

  var _module4 = babelHelpers.interopRequireDefault(_module3);

  exports.default = 42;
});
        JS

        assert_equal expected, es6_transformer.call(input)[:data]
      end

      def test_root_dir_must_be_a_directory
        assert_raises(RootDirectoryDoesNotExistError) do
          new_transformer(root_dir: nil)
        end

        assert_raises(RootDirectoryDoesNotExistError) do
          new_transformer(root_dir: __FILE__)
        end

        new_transformer(root_dir: File.expand_path(__dir__))
      end

      def test_cache_key
        cache_key = new_transformer(presets: ['es2015']).cache_key
        same_opts_transformer = new_transformer(presets: ['es2015'])
        assert_equal cache_key, same_opts_transformer.cache_key

        other_opts_transformer = new_transformer(presets: ['es2016'])
        refute_equal cache_key, other_opts_transformer.cache_key

        higher_version_transformer = new_transformer(babel_config_version: 2)
        refute_equal cache_key, higher_version_transformer.cache_key
      end

      def test_cache_key_from_input
        input = input_exemplar

        transformer_options = { presets: ['es2015'] }
        transformer = new_transformer(transformer_options)

        cache_key = transformer.cache_key_from_input(input)
        assert_equal cache_key, transformer.cache_key_from_input(input.dup)

        other_data = 'const square = (x) => x * x'
        cache_key_from_other_data =
          transformer.cache_key_from_input(input.merge(data: other_data))
        refute_equal cache_key, cache_key_from_other_data

        cache_key_from_other_filename =
          transformer.cache_key_from_input(input.merge(filename: 'x'))
        refute_equal cache_key, cache_key_from_other_filename

        cache_key_from_same_transformer_opts =
          new_transformer(transformer_options).cache_key_from_input(input)
        assert_equal cache_key, cache_key_from_same_transformer_opts

        cache_key_from_other_transformer_opts =
          new_transformer(presets: ['es2016']).cache_key_from_input(input)
        refute_equal cache_key, cache_key_from_other_transformer_opts

        cache_key_from_higher_version =
          new_transformer(babel_config_version: 2).cache_key_from_input(input)
        refute_equal cache_key, cache_key_from_higher_version
      end

      def test_cache_works
        input = input_exemplar

        presets = ['es2015']
        transformer = new_transformer(presets: presets)
        transformer.expects(:cache_key_from_input).with(input).returns('cache_key').twice

        mock_result = { 'code' => 'transformed' }
        babel_mock = mock(transform: mock_result)
        babel_mock.expects(:resolvePreset).with(presets.first)
        transformer.expects(:babel).returns(babel_mock).twice

        expected_output = { data: 'transformed' }
        assert_equal expected_output, transformer.call(input)
        assert_equal expected_output, transformer.call(input)

        transformer.expects(:cache_key_from_input).with(input).returns('new_key')

        transformer.expects(:babel).returns(mock(transform: mock_result)).once
        assert_equal expected_output, transformer.call(input)
      end

      def test_it_instantiates_resolver_only_the_first_time_call_is_invoked
        input = input_exemplar
        resolver = Resolver.new(Transformer::BabelBridge.new(File.expand_path(__dir__)))
        Resolver.expects(:new).never

        transformer = new_transformer(presets: ['es2015'])

        Resolver.expects(:new).returns(resolver).once

        transformer.call(input)
        other_input = input_exemplar(data: 'const foo = "bar"')
        transformer.call(other_input)
      end

      def test_it_resolves_plugin_arrays_the_first_time_call_is_invoked
        input = input_exemplar
        Resolver.any_instance.expects(:resolve_plugins).never

        plugins = nil
        transformer = new_transformer(plugins: plugins)
        transformer.call(input)

        plugins = 'external-helpers'
        transformer = new_transformer(plugins: plugins)
        transformer.call(input)

        plugins = ['external-helpers']
        transformer = new_transformer(plugins: plugins)

        Resolver.any_instance.expects(:resolve_plugins).with(plugins).once
        transformer.call(input)

        Resolver.any_instance.expects(:resolve_plugins).never
        other_input = input_exemplar(data: 'const foo = "bar"')
        transformer.call(other_input)
      end

      def test_it_resolves_preset_arrays_the_first_time_call_is_invoked
        input = input_exemplar
        Resolver.any_instance.expects(:resolve_presets).never

        presets = nil
        transformer = new_transformer(presets: presets)
        transformer.call(input)

        presets = 'es2015'
        transformer = new_transformer(presets: presets)
        transformer.call(input)

        presets = ['es2015']
        transformer = new_transformer(presets: presets)

        Resolver.any_instance.expects(:resolve_presets).with(presets).once
        transformer.call(input)

        Resolver.any_instance.expects(:resolve_presets).never
        other_input = input_exemplar(data: 'const foo = "bar"')
        transformer.call(other_input)
      end

      private

      def new_transformer(options)
        default_options = {
          root_dir: File.expand_path(__dir__),
          babel_config_version: 1
        }
        Transformer.new(default_options.merge(options))
      end

      def input_exemplar(overrides = {})
        {
          content_type: 'application/ecmascript-6',
          data:         'const square = (n) => n * n',
          metadata:     {},
          load_path:    File.expand_path('../foo', __FILE__),
          filename:     File.expand_path('../foo/bar.es6', __FILE__),
          cache:        Sprockets::Cache.new
        }.merge(overrides)
      end
    end
  end
end
