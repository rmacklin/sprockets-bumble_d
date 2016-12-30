//= require foo
//= require bar

(function(Foo, Bar) {
  Foo = Foo.default;
  Bar = Bar.default;

  console.log(new Bar().foo.number);
  console.log(new Foo().number);
})(Foo, Bar);
