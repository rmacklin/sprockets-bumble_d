$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "test_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "test_engine"
  s.version     = TestEngine::VERSION
  s.authors     = ["Richard Macklin"]
  s.summary     = "Summary of TestEngine."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.7.1"
end
