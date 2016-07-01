require 'schmooze/base'
require 'sprockets/path_utils'

module Sprockets
  module BumbleD
    class Transformer
      class BabelBridge < Schmooze::Base
        dependencies babel: 'babel-core'

        method :transform, 'babel.transform'
      end

      def initialize(options)
        @options = options.dup
        @root_dir = @options.delete(:root_dir)
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def call(input)
        data = input[:data]

        filename_relative = Sprockets::PathUtils.split_subpath(
          input[:load_path],
          input[:filename]
        )

        options = {
          moduleIds: true,
          sourceRoot: input[:load_path],
          moduleRoot: nil,
          filename: input[:filename],
          filenameRelative: filename_relative,
          ast: false
        }.merge(@options)

        if options[:moduleIds] && options[:moduleRoot]
          options[:moduleId] ||= File.join(options[:moduleRoot], input[:name])
        elsif options[:moduleIds]
          options[:moduleId] ||= input[:name]
        end

        result = babel.transform(data, options)

        { data: result['code'] }
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def babel
        @babel ||= BabelBridge.new(@root_dir)
      end
    end
  end
end
