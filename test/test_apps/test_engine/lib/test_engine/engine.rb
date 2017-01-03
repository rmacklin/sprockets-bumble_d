module TestEngine
  class Engine < ::Rails::Engine
    isolate_namespace TestEngine

    extend Sprockets::BumbleD::DSL

    register_umd_globals :test_engine,
      'test_engine/baz' => 'TestEngine.Baz',
      'test_engine/qux' => 'TestEngine.Qux'
  end
end
