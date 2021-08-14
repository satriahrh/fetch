# frozen_string_literal: true

require 'uri'

module Fetch
  module Model
    # Resource is the object we will be using in the
    # chain of command in this program.
    class Resource
      attr_accessor :response,
                    :relative_filepath,
                    :base_directory,
                    :images,
                    :images_content,
                    :links,
                    :metadata

      attr_reader :uri

      def initialize(full_url)
        self.uri = full_url
        self.metadata = {}
        self.images = []
        self.images_content = {}
      end

      def uri=(new_value)
        if [URI::HTTPS, URI::HTTP].include? new_value.class
          @uri = new_value
        else
          @uri = URI.parse new_value
        end

        raise Fetch::Error::ResourceInvalidURI unless
          [URI::HTTPS, URI::HTTP].include? @uri.class

        @uri
      end

      def to_s
        "Resource of #{@uri}"
      end
    end
  end
end
