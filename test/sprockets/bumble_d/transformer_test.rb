require 'test_helper'

require 'sprockets/cache'
require 'sprockets/bumble_d/transformer'

module Sprockets
  module BumbleD
    class TransformerTest < Minitest::Test
      def test_it_compiles_es6_features_to_es5
        input = {
          content_type: 'application/ecmascript-6',
          data: 'const square = (n) => n * n',
          metadata: {},
          load_path: File.expand_path('../foo', __FILE__),
          filename: File.expand_path('../foo/bar.es6', __FILE__),
          cache: Sprockets::Cache.new
        }

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

        input = {
          content_type: 'application/ecmascript-6',
          data: es6_module,
          metadata: {},
          load_path: File.expand_path('../some/dir', __FILE__),
          filename: File.expand_path('../some/dir/mod.es6', __FILE__),
          cache: Sprockets::Cache.new,
          name: 'some/dir/mod'
        }

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

        input = {
          content_type: 'application/ecmascript-6',
          data: es6_module,
          metadata: {},
          load_path: File.expand_path('../some/dir', __FILE__),
          filename: File.expand_path('../some/dir/mod.es6', __FILE__),
          cache: Sprockets::Cache.new,
          name: 'some/dir/mod'
        }

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
        input = {
          content_type: 'application/ecmascript-6',
          data: 'const square = (n) => n * n',
          metadata: {},
          load_path: File.expand_path('../foo', __FILE__),
          filename: File.expand_path('../foo/bar.es6', __FILE__),
          cache: Sprockets::Cache.new
        }

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
        input = {
          content_type: 'application/ecmascript-6',
          data: 'const square = (n) => n * n',
          metadata: {},
          load_path: File.expand_path('../foo', __FILE__),
          filename: File.expand_path('../foo/bar.es6', __FILE__),
          cache: Sprockets::Cache.new
        }

        transformer = new_transformer(presets: ['es2015'])
        transformer.expects(:cache_key_from_input).with(input).returns('cache_key').twice

        mock_result = { 'code' => 'transformed' }
        transformer.expects(:babel).returns(mock(transform: mock_result)).once

        expected_output = { data: 'transformed' }
        assert_equal expected_output, transformer.call(input)
        assert_equal expected_output, transformer.call(input)

        transformer.expects(:cache_key_from_input).with(input).returns('new_key')

        transformer.expects(:babel).returns(mock(transform: mock_result)).once
        assert_equal expected_output, transformer.call(input)
      end

      private

      def new_transformer(options)
        default_options = {
          root_dir: File.expand_path(__dir__),
          babel_config_version: 1
        }
        Transformer.new(default_options.merge(options))
      end
    end
  end
end
