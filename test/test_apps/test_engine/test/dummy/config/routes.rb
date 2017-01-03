Rails.application.routes.draw do

  mount TestEngine::Engine => "/test_engine"
end
