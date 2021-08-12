# frozen_string_literal: true

module Fetch
  module Service
    # StoreResponse is base class of storing/caching
    # a http response to file
    class StoreResponse < Fetch::Service::Base
      def before_process
        raise 'response body is empty' if
          @resource&.response&.body&.empty?
      end

      def process
        split_directory_from_resource_uri
        create_base_directory
        create_filepath
        store_to_filepath
      end

      protected

      def filename
        raise NotImplementedError
      end

      private

      def split_directory_from_resource_uri
        host = @resource.uri.host
        paths = @resource.uri.path.split '/'
        @directory_splitted = [host] + paths
      end

      def create_base_directory
        @resource.base_directory = Dir.getwd
        @directory_splitted.each do |dirname|
          @resource.base_directory = File.join @resource.base_directory, dirname
          Dir.mkdir @resource.base_directory unless Dir.exist? @resource.base_directory
        end
      end

      def create_filepath
        @resource.filename = filename
        @filepath = File.join @resource.base_directory, @resource.filename
      end

      def store_to_filepath
        File.delete @filepath if File.exist? @filepath
        file = File.new(@filepath, File::CREAT | File::RDWR, 777)
        file.write(@resource.response.body)
        file.close
      end
    end

    # StoreResponseHtml is to storing/caching specifically
    # html response
    class StoreResponseHtml < Fetch::Service::StoreResponse
      protected

      def before_process
        super
        content_type = @resource.response.content_type
        raise "not an html response, found #{content_type}" unless
          content_type == 'text/html'
      end

      def filename
        'index.html'
      end
    end
  end
end
