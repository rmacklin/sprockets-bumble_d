$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sprockets/bumble_d'

require 'minitest/autorun'
require 'mocha/setup'

# This require is necessary because ActiveSupport (pulled in by requiring
# railties) redefines to_json to call ActiveSupport::JSON.encode(self, options)
# which ends up raising a NameError: uninitialized constant ActiveSupport::JSON
# when Schmooze calls to_json. (Since we're not in a Rails app, that constant
# isn't autoloaded.)
require 'active_support/json/encoding'
