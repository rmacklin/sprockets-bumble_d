# Changelog

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
