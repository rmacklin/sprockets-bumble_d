# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sprockets/bumble_d/version'

Gem::Specification.new do |spec|
  spec.name          = 'sprockets-bumble_d'
  spec.version       = Sprockets::BumbleD::VERSION
  spec.authors       = ['Richard Macklin']

  spec.summary       = 'Let Sprockets use Babel to transpile ES6 modules to UMD'
  spec.description   = <<-EOF
    Babel + UMD = BumbleD
    Facilitate incremental migration of a large Sprockets-powered javascript
    codebase to ES6 modules by transforming them to UMD modules that preserve
    your existing global references.
  EOF
  spec.homepage      = 'https://github.com/rmacklin/sprockets-bumble_d'
  spec.license       = 'MIT'

  spec.files         = Dir['{lib}/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'railties', '~> 4.2'
  spec.add_dependency 'schmooze', '0.1.6'
  spec.add_dependency 'sprockets', '~> 3.5'
end
