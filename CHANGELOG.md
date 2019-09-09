# Changelog

## 2.2.0

Support rails 6

## 2.1.0

Default the `root_dir` setting to `Rails.root.to_s` in Rails applications

Make the sprockets transformer extension configurable

## 2.0.0

Upgrade to support babel 7. If you need to use babel 6, you can still use Sprockets::BumbleD version 1.1

## 1.1.0

Defer execution of babel plugin and preset resolution until the first time `Transformer#call` is invoked.

This prevents an exception from being raised if the railtie is loaded before node modules have been installed.
As long as the babel packages are installed before `call` is invoked, you're good to go.

## 1.0.0

Support transforming to other module formats by adding `transform_to_umd` flag

## 0.4.0

Pass babel plugins and presets as absolute paths so that they can be found even when transpiling files outside the package.json subtree

This relies on methods introduced in babel-core 6.22.0 (https://github.com/babel/babel/pull/4729)

## 0.3.0

Support rails 5

## 0.2.0

Switch to using `register_engine` to avoid sprockets regression (https://github.com/rails/sprockets/issues/384)

## 0.1.0

Initial version
