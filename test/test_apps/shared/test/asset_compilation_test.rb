require 'test_helper'

class AssetCompilationTest < Minitest::Test
  def test_compiled_assets_are_correct
    Rake::Task['assets:precompile'].invoke
    compiled_main_js_file = File.expand_path("../../public/assets/main-#{MAIN_JS_DIGEST}.js", __FILE__)
    assert_equal EXPECTED_OUTPUT, File.read(compiled_main_js_file)
  end

  MAIN_JS_DIGEST = 'e4c5718ffe99c510d5bafab365ef312e5e65617f0317d2e62507e3420eebecfa'
  EXPECTED_OUTPUT = <<-JS
(function (global, factory) {
  if (typeof define === "function" && define.amd) {
    define("test_engine/qux", ["exports"], factory);
  } else if (typeof exports !== "undefined") {
    factory(exports);
  } else {
    var mod = {
      exports: {}
    };
    factory(mod.exports);
    global.TestEngine = global.TestEngine || {};
    global.TestEngine.Qux = mod.exports;
  }
})(this, function (_exports) {
  "use strict";

  Object.defineProperty(_exports, "__esModule", {
    value: true
  });
  _exports.default = void 0;

  function Qux(config) {
    this.config = config;
  }

  var _default = Qux;
  _exports.default = _default;
});
(function (global, factory) {
  if (typeof define === "function" && define.amd) {
    define("foo", ["exports"], factory);
  } else if (typeof exports !== "undefined") {
    factory(exports);
  } else {
    var mod = {
      exports: {}
    };
    factory(mod.exports);
    global.Foo = mod.exports;
  }
})(this, function (_exports) {
  "use strict";

  Object.defineProperty(_exports, "__esModule", {
    value: true
  });
  _exports.default = void 0;

  function Foo() {
    this.number = 42;
  }

  var _default = Foo;
  _exports.default = _default;
});
(function (global, factory) {
  if (typeof define === "function" && define.amd) {
    define("bar", ["exports", "foo"], factory);
  } else if (typeof exports !== "undefined") {
    factory(exports, require("foo"));
  } else {
    var mod = {
      exports: {}
    };
    factory(mod.exports, global.Foo);
    global.Bar = mod.exports;
  }
})(this, function (_exports, _foo) {
  "use strict";

  Object.defineProperty(_exports, "__esModule", {
    value: true
  });
  _exports.default = void 0;
  _foo = babelHelpers.interopRequireDefault(_foo);

  function Bar() {
    this.foo = new _foo.default();
  }

  var _default = Bar;
  _exports.default = _default;
});





(function(Foo, Bar, Qux) {
  Foo = Foo.default;
  Bar = Bar.default;
  Qux = Qux.default;

  console.log(new Bar().foo.number);
  console.log(new Foo().number);
  console.log(new Qux({a: 1}).config.a);
})(Foo, Bar, TestEngine.Qux);
  JS
end
