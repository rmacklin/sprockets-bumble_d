require 'schmooze/base'
require 'sprockets/path_utils'
require 'sprockets/bumble_d/errors'
require 'sprockets/bumble_d/version'

module Sprockets
  module BumbleD
    class Transformer
      class BabelBridge < Schmooze::Base
        dependencies babel: 'babel-core'

        method :resolvePlugin, 'babel.resolvePlugin'
        method :resolvePreset, 'babel.resolvePreset'
        method :transform, 'babel.transform'
      end

      attr_reader :cache_key

      # TODO: extract resolution logic
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity,
      # rubocop:disable Metrics/PerceivedComplexity

      # rubocop:disable Metrics/MethodLength
      def initialize(options)
        @options = options.dup
        @root_dir = @options.delete(:root_dir)
        babel_config_version = @options.delete(:babel_config_version)

        unless @root_dir && File.directory?(@root_dir)
          error_message =
            'You must provide the `root_dir` directory from which ' \
            'node modules are to be resolved'
          raise RootDirectoryDoesNotExistError, error_message
        end

        if @options[:plugins].is_a?(Array)
          @options[:plugins] = @options[:plugins].map do |plugin|
            if plugin.is_a?(Array)
              [babel.resolvePlugin(plugin[0]), plugin[1]]
            else
              babel.resolvePlugin(plugin)
            end
          end
        end

        if @options[:presets].is_a?(Array)
          @options[:presets] = @options[:presets].map do |preset|
            if preset.is_a?(Array)
              [babel.resolvePreset(preset[0]), preset[1]]
            else
              babel.resolvePreset(preset)
            end
          end
        end

        @cache_key = [
          self.class.name,
          VERSION,
          babel_config_version,
          @options
        ].freeze
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity,
      # rubocop:enable Metrics/PerceivedComplexity

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def call(input)
        data = input[:data]

        result = input[:cache].fetch(cache_key_from_input(input)) do
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

          babel.transform(data, options)
        end

        { data: result['code'] }
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def cache_key_from_input(input)
        @cache_key + [input[:filename]] + [input[:data]]
      end

      def babel
        @babel ||= BabelBridge.new(@root_dir)
      end
    end
  end
end
