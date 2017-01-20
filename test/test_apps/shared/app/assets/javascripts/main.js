//= require test_engine/qux

//= require foo
//= require bar

(function(Foo, Bar, Qux) {
  Foo = Foo.default;
  Bar = Bar.default;
  Qux = Qux.default;

  console.log(new Bar().foo.number);
  console.log(new Foo().number);
  console.log(new Qux({a: 1}).config.a);
})(Foo, Bar, TestEngine.Qux);
