require 'test_helper'

class AssetCompilationTest < Minitest::Test
  def test_compiled_assets_are_correct
    Rake::Task['assets:precompile'].invoke
    compiled_main_js_file = File.expand_path("../../public/assets/main-#{MAIN_JS_DIGEST}.js", __FILE__)
    assert_equal EXPECTED_OUTPUT, File.read(compiled_main_js_file)
  end

  MAIN_JS_DIGEST = '4e9dc3128cbfb0e86b21cae6c5d846a3574e7e1e088e6e630d8200694e7868a4'
  EXPECTED_OUTPUT = <<-JS
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
})(this, function (exports) {
  "use strict";

  Object.defineProperty(exports, "__esModule", {
    value: true
  });
  function Foo() {
    this.number = 42;
  }

  exports.default = Foo;
});
(function (global, factory) {
  if (typeof define === "function" && define.amd) {
    define('bar', ['exports', 'foo'], factory);
  } else if (typeof exports !== "undefined") {
    factory(exports, require('foo'));
  } else {
    var mod = {
      exports: {}
    };
    factory(mod.exports, global.Foo);
    global.Bar = mod.exports;
  }
})(this, function (exports, _foo) {
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



(function(Foo, Bar) {
  Foo = Foo.default;
  Bar = Bar.default;

  console.log(new Bar().foo.number);
  console.log(new Foo().number);
})(Foo, Bar);
  JS
end
