# frozen_string_literal: true

require 'uri'

module Fetch
  module Model
    # Resource is the object we will be using in the
    # chain of command in this program.
    class Resource
      attr_accessor :response,
                    :base_directory,
                    :filename,
                    :images,
                    :links,
                    :metadata

      attr_reader :uri

      def initialize(full_url)
        self.uri = full_url
        self.metadata = {}
      end

      def uri=(new_value)
        @uri = URI.parse new_value
        raise Fetch::Error::ResourceInvalidURI unless
          [URI::HTTPS, URI::HTTP].include? @uri.class
      end

      def to_s
        "Resource of #{@uri}"
      end
    end
  end
end
