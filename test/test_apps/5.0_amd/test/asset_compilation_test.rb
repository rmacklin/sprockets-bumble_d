require 'test_helper'

class AssetCompilationTest < Minitest::Test
  def test_compiled_assets_are_correct
    Rake::Task['assets:precompile'].invoke
    compiled_main_js_file = File.expand_path("../../public/assets/main-#{MAIN_JS_DIGEST}.js", __FILE__)
    assert_equal EXPECTED_OUTPUT, File.read(compiled_main_js_file)
  end

  MAIN_JS_DIGEST = 'f4b4c2aa0b687f7aa0fb7e430800b58a3b646bf1301763fd9b1116deb0c7e278'
  EXPECTED_OUTPUT = <<-JS
define("test_engine/qux", ["exports"], function (_exports) {
  "use strict";

  Object.defineProperty(_exports, "__esModule", {
    value: true
  });
  _exports["default"] = void 0;

  function Qux(config) {
    this.config = config;
  }

  var _default = Qux;
  _exports["default"] = _default;
});
define("foo", ["exports"], function (_exports) {
  "use strict";

  Object.defineProperty(_exports, "__esModule", {
    value: true
  });
  _exports["default"] = void 0;

  function Foo() {
    this.number = 42;
  }

  var _default = Foo;
  _exports["default"] = _default;
});
define("bar", ["exports", "foo"], function (_exports, _foo) {
  "use strict";

  Object.defineProperty(_exports, "__esModule", {
    value: true
  });
  _exports["default"] = void 0;
  _foo = babelHelpers.interopRequireDefault(_foo);

  function Bar() {
    this.foo = new _foo["default"]();
  }

  var _default = Bar;
  _exports["default"] = _default;
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
