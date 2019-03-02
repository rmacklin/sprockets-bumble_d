require 'sprockets/bumble_d/errors'

module Sprockets
  module BumbleD
    class Config
      attr_accessor :babel_config_version,
                    :babel_options,
                    :file_extension,
                    :root_dir,
                    :transform_to_umd
      attr_reader :globals_map

      def initialize
        @file_extension = '.es6'
        @globals_map = {}.freeze
        @transform_to_umd = true
        @babel_options = {
          presets: ['@babel/preset-env'],
          plugins: ['@babel/plugin-external-helpers']
        }
      end

      def configure
        yield self
      end

      def register_globals(globals_map)
        duplicate_keys = @globals_map.keys & globals_map.keys
        unless duplicate_keys.empty?
          error_message = "Duplicate keys registered: #{duplicate_keys}"
          raise ConflictingGlobalRegistrationError, error_message
        end

        @globals_map = @globals_map.merge(globals_map).freeze
      end
    end
  end
end
