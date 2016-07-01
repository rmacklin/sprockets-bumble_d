module Sprockets
  module BumbleD
    class Error < StandardError; end

    class ConflictingGlobalRegistrationError < Error; end
    class RootDirectoryDoesNotExistError < Error; end
  end
end
