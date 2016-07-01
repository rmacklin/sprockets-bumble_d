require 'sprockets/bumble_d/errors'

module Sprockets
  module BumbleD
    class Config
      attr_accessor :babel_options, :root_dir
      attr_reader :globals_map

      def initialize
        @globals_map = {}.freeze
        @babel_options = {
          presets: ['es2015'],
          plugins: ['external-helpers']
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
