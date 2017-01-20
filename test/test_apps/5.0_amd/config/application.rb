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
      config.root_dir = File.expand_path('..', __dir__)
      config.babel_config_version = 1
      config.transform_to_umd = false
      config.babel_options = {
        presets: ['es2015'],
        plugins: ['external-helpers', 'transform-es2015-modules-amd']
      }
    end
  end
end
