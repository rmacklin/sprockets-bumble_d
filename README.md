# Sprockets::BumbleD

[Babel](https://babeljs.io) + [UMD](https://github.com/umdjs/umd) = BumbleD.
Incrementally migrate your Sprockets-powered javascript to ES6 modules by
[transforming](https://en.wikipedia.org/wiki/Bumblebee_(Transformers)) them
to UMD modules that preserve your existing global references.

## Background

ES6 modules are the future. The syntax is great: it's concise and
straightforward, and the static and explicit nature of `import` and `export`
statements make your code a complete spec of its dependencies and how to
resolve them. This means that moving to ES6 modules also makes moving away
from Sprockets `//= require` directives for javascript bundling (and Sprockets
in general) much easier.

But when faced with a large codebase, it's not feasible to convert everything
to ES6 modules at once. Thus, the goal is to be able to convert
module-by-module from explicitly exporting a global (and depending on other
globals) to following the ES6 module format, which we'll then transpile to UMD
that is compatible with non-converted code (e.g. existing UMD modules and
plain old global-dependent scripts).

Sprockets::BumbleD provides this with a Sprockets transformer that acts on
`.es6` files. These files are transpiled by Babel and the
[ES2015 -> UMD modules transform] plugin, preserving any globals that you've
[registered](#registering-globals).

[ES2015 -> UMD modules transform]: https://github.com/babel/babel/tree/v7.3.4/packages/babel-plugin-transform-modules-umd

## Setup

### Installation

1. Add `gem 'sprockets-bumble_d'` to your `Gemfile` (or add a gemspec
dependency to an [inline engine](#inline-rails-engines) in your app) and
run `bundle install`.
2. Run `npm install --save @babel/core @babel/plugin-external-helpers @babel/plugin-transform-modules-umd @babel/preset-env`
to install the modules for the default babel config. If you want to
[customize the babel options](#customizing-your-babel-options), install any
additional plugins and presets you want.
3. Generate the [external helpers] and `//= require` them in at the beginning
of your application manifest or pull them in with a separate script tag. This
step is of course unnecessary if you won't be using the external-helpers
plugin, but it's highly recommended that you do (to avoid inlining them
everywhere, which unnecessarily bloats the bundle sent to the browser).

[external helpers]: https://babeljs.io/docs/plugins/external-helpers

### Basic configuration

In `config/application.rb`:
```ruby
extend Sprockets::BumbleD::DSL

configure_sprockets_bumble_d do |config|
  config.root_dir = File.expand_path('..', __dir__)
  config.babel_config_version = 1
end
```

The `root_dir` setting is **required**! This tells Sprockets::BumbleD the
directory from which node modules are to be resolved (typically, wherever your
package.json resides). If that's `Rails.root.to_s`, use that. If it's in a
specific subdirectory, specify that. Sprockets::BumbleD doesn't care, as long
as its node `require` statements will resolve from that directory.

### Customizing your babel options

By default you get [@babel/preset-env], [@babel/plugin-external-helpers], and
[@babel/plugin-transform-modules-umd]. If you want to customize this with
different plugins and presets, specify them in the
`configure_sprockets_bumble_d` block with the `babel_options` setting. Note
that (because it's central to the purpose of this gem)
@babel/plugin-transform-modules-umd is _always_ included for you (unless
you [set `transform_to_umd` to `false`](#do-i-have-to-transpile-to-umd-modules))
and configured to use the [registered globals](#registering-globals), so this
plugin does not need to be specified when you override the default plugins.

[@babel/preset-env]: https://babeljs.io/docs/en/babel-preset-env
[@babel/plugin-external-helpers]: https://babeljs.io/docs/en/babel-plugin-external-helpers
[@babel/plugin-transform-modules-umd]: https://babeljs.io/docs/en/babel-plugin-transform-modules-umd

For example:
```ruby
configure_sprockets_bumble_d do |config|
  config.root_dir = File.expand_path('..', __dir__)
  config.babel_config_version = 2
  config.babel_options = {
    presets: ['@babel/preset-env', '@babel/preset-react'],
    plugins: ['@babel/plugin-external-helpers', 'custom-plugin']
  }
end
```

You can specify any options that are allowed in a `.babelrc` file.

### The `babel_config_version` setting

What's this mysterious `babel_config_version` we're setting in the previous
examples? Good question. Essentially this is intended to be a value that
translates to the composite version of babel-core and each babel preset
and plugin in your application. It's used to expire the cache for compiled
assets: since different versions of babel and its plugins can result in a
different transpiled output, we want to be able to invalidate the cache
whenever we change our babel configuration. So, when you upgrade babel-core
or you add/remove/upgrade a babel plugin or preset, you'd increment this
version which will cause the Sprockets transformer's cache key to change.

### Philosophy

You should own your babel setup. We want to be able to use the latest versions
of babel and its plugins as soon as they're available, so this gem doesn't
vendor any node modules - it's up to the application to provide those to the
gem. This is what the `root_dir` config is for. It's also why the
`babel_config_version` setting exists.

### Registering globals

@babel/plugin-transform-modules-umd includes an `exactGlobals` option that lets
you specify exactly how to transpile any import statements into the global
reference it should resolve to. It also lets you specify what global should be
exported by an ES6 module in the resultant UMD output. (A complete description
is available in [babel PR #3534]).

[babel PR #3534]: (https://github.com/babel/babel/pull/3534)

In `config/application.rb`, after `extend Sprockets::BumbleD::DSL`:
```ruby
register_umd_globals :my_app,
  'my/great/thing' => 'MyGreatThing',
  'her/cool/tool'  => 'herCoolTool'
```

Doing this will allow:
```js
import GreatThing from 'my/great/thing';
```
to be transpiled to:
```js
factory(/* ... */ global.MyGreatThing);
```
in the globals branch of the transpiled UMD output. Similarly, the above map
also specifies that the exports of the ES6 module `her/cool/tool` will be
assigned to the `herCoolTool` global.

That is, registering these globals provides both:
- a way to depend on existing globals in ES6 modules
- a way to declare the global an ES6 module should export, to be used in
existing UMD modules or direct global references

As a corollary, if you are writing a new ES6 module that is only used by other
ES6 modules, you would not need to register a global for that module's export.

Exported globals can also be nested objects and the transform will properly
handle creating the necessary prerequisite assignments. For example with this
registration:
```ruby
register_umd_globals :my_app,
  'her/cool/tool' => 'Her.Cool.Tool'
```
the compiled `her/cool/tool` module will contain:
```js
global.Her = global.Her || {};
global.Her.Cool = global.Her.Cool || {};
global.Her.Cool.Tool = mod.exports;
```

#### Inline Rails engines

If you have a large application, you may have split it into multiple inline
rails engines (as described in [this talk]). Inline engines with their own
assets should own the registration of globals for these assets. This is
supported in Sprockets::BumbleD:

[this talk]: https://www.youtube.com/watch?v=-54SDanDC00

in `some_engine/engine.rb`:
```ruby
extend Sprockets::BumbleD::DSL

register_umd_globals :some_engine,
  'some_namespace/first_module'  => 'SomeNamespace.firstModule',
  'some_namespace/second_module' => 'SomeNamespace.secondModule',
  'another_thing/mod'            => 'anotherModule'
```

Since module globals should only be registered in the engine (or top level
application) where the module lives, `register_umd_globals` will raise
`Sprockets::BumbleD::ConflictingGlobalRegistrationError` if a module is
registered a second time. Of course, this still can't prevent you from
registering globals (that had not already been registered) in the wrong engine.

### Reminder about Rails reloading

As with any `config` changes, updates to the globals registry are not
reloaded automatically; you must restart your server for the changes to take
effect.

### Do I have to transpile to UMD modules?

No, you can transpile to other module formats (e.g. AMD). You'd just be using
less of this gem's API surface area <sup>1</sup>. You can set `transform_to_umd` to
`false` in your `configure_sprockets_bumble_d` block, and
[override the default plugins](#customizing-your-babel-options) to use a
different module transform. For example if you're using an AMD loader like
[almond], you could configure modules to be transpiled to AMD like so:

[almond]: https://github.com/requirejs/almond

```rb
configure_sprockets_bumble_d do |config|
  config.root_dir = File.expand_path('..', __dir__)
  config.babel_config_version = 1
  config.transform_to_umd = false
  config.babel_options = {
    presets: ['@babel/preset-env'],
    plugins: ['@babel/plugin-external-helpers', '@babel/plugin-transform-modules-amd']
  }
end
```

You can reference the [5.0_amd test app](./test/test_apps/5.0_amd) which
demonstrates this in a full application.

<sup><sup>1</sup> Of course if you're doing this, you wouldn't ever call
`register_umd_globals`</sup>

## Similar projects

- [babel-schmooze-sprockets] - This takes a similar approach, but it requires
  sprockets 4 (which is still in beta), and it doesn't offer a way to register
  globals within inline engines. Additionally, it diverges in
  [philosophy](#philosophy) by vendoring some node_modules.
- [sprockets-es6] - This has been the common solution for ES6 transpilation in
  sprockets for a while, but it takes a very different approach. Instead of
  relying on node and the npm ecosystem, it uses [ruby-babel-transpiler], which
  is stuck on babel 5. This means you cannot configure custom babel plugins
  (which means you can't use `exactGlobals` to specify what it should transform
  globals to in the UMD modules transform).
- [sprockets 4] - This takes the same approach as sprockets-es6 so it suffers
  from the same limitations as sprockets-es6

[babel-schmooze-sprockets]: https://github.com/fnando/babel-schmooze-sprockets
[ruby-babel-transpiler]: https://github.com/babel/ruby-babel-transpiler
[sprockets-es6]: https://github.com/TannerRogalsky/sprockets-es6
[sprockets 4]: https://github.com/rails/sprockets/tree/v4.0.0.beta4
