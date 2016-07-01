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
    end
  end
end
