require 'test_helper'

require 'sprockets/bumble_d/config'

module Sprockets
  module BumbleD
    class ConfigTest < Minitest::Test
      def test_register_globals
        config = Config.new

        assert_equal ({}), config.globals_map
        assert_predicate config.globals_map, :frozen?

        first_globals = {
          'foo' => 'bar',
          'baz' => 'qux'
        }
        config.register_globals(first_globals)

        assert_equal first_globals, config.globals_map
        assert_predicate config.globals_map, :frozen?

        second_globals = {
          'bob' => 'donnie',
          'jon' => 'daniel'
        }
        config.register_globals(second_globals)

        assert_equal first_globals.merge(second_globals), config.globals_map
        assert_predicate config.globals_map, :frozen?

        globals_with_duplicate_key = {
          'foo' => 'd',
          'bob' => 'by'
        }

        error = assert_raises(ConflictingGlobalRegistrationError) do
          config.register_globals(globals_with_duplicate_key)
        end

        assert_equal 'Duplicate keys registered: ["foo", "bob"]', error.message
      end

      def test_configure
        config = Sprockets::BumbleD::Config.new

        assert_nil config.root_dir
        assert_nil config.babel_options

        custom_babel_options = {
          presets: ['es2015', 'react'],
          plugins: ['external-helpers', 'custom-plugin']
        }

        config.configure do |c|
          c.root_dir = File.expand_path(__dir__)
          c.babel_options = custom_babel_options
        end

        assert_equal File.expand_path(__dir__), config.root_dir
        assert_equal custom_babel_options, config.babel_options
      end
    end
  end
end
