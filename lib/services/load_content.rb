# frozen_string_literal: true

require 'net/http'

module Fetch
  module Service
    # LoadHTML is to fetch the content from given URI
    class LoadHTML < Fetch::Service::Base
      def before_process
        raise 'resource should be an instance of Fetch::Model::Resource' unless
          [URI::HTTPS, URI::HTTP].include? @resource&.uri.class
      end

      def process
        uri = @resource.uri
        @resp = Net::HTTP.get_response(uri)
      end

      def after_process
        raise 'Get not OK response from given url' unless
          @resp.instance_of? Net::HTTPOK

        @resource.response = @resp
        @resource.metadata[:last_fetch] = Time.now
      end
    end

    class LoadImages < Fetch::Service::Base
    end
  end
end
