require 'test_helper'

class AssetCompilationTest < Minitest::Test
  def test_compiled_assets_are_correct
    Rake::Task['assets:precompile'].invoke
    compiled_main_js_file = File.expand_path("../../public/assets/main-#{MAIN_JS_DIGEST}.js", __FILE__)
    assert_equal EXPECTED_OUTPUT, File.read(compiled_main_js_file)
  end

  MAIN_JS_DIGEST = '21183860c3b361482291ccf49088bfec609576fac9b1843d93b8c87f3bcde54a'
  EXPECTED_OUTPUT = <<-JS
define("test_engine/qux", ["exports"], function (exports) {
  "use strict";

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  function Qux(config) {
    this.config = config;
  }

  exports.default = Qux;
});
define("foo", ["exports"], function (exports) {
  "use strict";

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  function Foo() {
    this.number = 42;
  }

  exports.default = Foo;
});
define('bar', ['exports', 'foo'], function (exports, _foo) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });

  var _foo2 = babelHelpers.interopRequireDefault(_foo);

  function Bar() {
    this.foo = new _foo2.default();
  }

  exports.default = Bar;
});





require(['foo', 'bar', 'test_engine/qux'], function(Foo, Bar, Qux) {
  Foo = Foo.default;
  Bar = Bar.default;
  Qux = Qux.default;

  console.log(new Bar().foo.number);
  console.log(new Foo().number);
  console.log(new Qux({a: 1}).config.a);
});
  JS
end
