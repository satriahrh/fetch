# frozen_string_literal: true

require 'net/http'
require 'uri'

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
      def before_process
        raise 'resource should be an instance of Fetch::Model::Resource' unless
          [URI::HTTPS, URI::HTTP].include? @resource&.uri.class
      end

      def process
        @images_content = {}
        @resource.images.each do |image_path, _|
          next if data_uri?(image_path)

          image_uri = image_path
          unless URI::DEFAULT_PARSER.make_regexp(%w[http https]).match? image_path
            image_uri = URI.join("#{@resource.uri.scheme}://#{@resource.uri.host}", image_path)
          else
            image_uri = URI.parse image_uri
          end

          image_resource = Fetch::Model::Resource.new image_uri
          image_resource.response = Net::HTTP.get_response(image_uri)
          @images_content[image_path] = image_resource
        end
      end

      def after_process
        @resource.images_content = @images_content
      end

      private

      def data_uri?(src)
        # due to https://gist.github.com/khanzadimahdi/bab8a3416bdb764b9eda5b38b35735b8
        data_uri_schema_regex = %r{^data:((?:\w+/(?:(?!;).)+)?)((?:;[\w\W]*?[^;])*),(.+)$}
        data_uri_schema_regex.match?(src)
      end
    end
  end
end
