require_relative 'boot'

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TestApp
  class Application < Rails::Application
    extend Sprockets::BumbleD::DSL

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    configure_sprockets_bumble_d do |config|
      config.babel_config_version = 1
    end

    register_umd_globals :test_app,
      'bar' => 'Bar',
      'foo' => 'Foo'
  end
end
