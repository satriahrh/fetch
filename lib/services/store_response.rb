# frozen_string_literal: true

require 'json'

module Fetch
  module Service
    # StoreResponse is base class of storing/caching
    # a http response to file
    class StoreResponse < Fetch::Service::Base
      def before_process
        raise 'response body is empty' unless
          @resource&.content&.to_html
      end

      def process
        Fetch::Helper::StoreToFile.new(
          @resource.relative_filepath,
          @resource.content.to_html,
          @resource.base_directory
        )
      end

      def after_process
        relative_dir, _ = File.split @resource.relative_filepath
        Fetch::Helper::StoreToFile.new(
          'meta.json',
          JSON.generate(@resource.metadata),
          File.join(@resource.base_directory, relative_dir)
        )
      end
    end
  end
end
