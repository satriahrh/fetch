# frozen_string_literal: true

require 'net/http'

module Fetch
  module Service
    # LoadContent is to fetch the content from given URI
    class LoadContent < Fetch::Service::Base
      def process
        uri = @resource.uri
        resp = Net::HTTP.get_response(uri)
        @resource.response = resp
      end
    end
  end
end
