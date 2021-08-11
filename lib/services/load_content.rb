require 'net/http'

module Fetch
  module Service
    class LoadContent < Fetch::Service::Base
      def process
        uri = @resource.uri
        resp = Net::HTTP.get_response(uri)
        @resource.response = resp
      end
    end
  end
end
