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
        relative_dirname, filename = File.split relative_filepath
        base_relative_directory = base_directory
        relative_dirname.split('/').each do |dirname|
          base_relative_directory = File.join base_relative_directory, dirname
          Dir.mkdir base_relative_directory unless Dir.exist? base_relative_directory
        end

        absolute_filepath = File.join base_relative_directory, filename
        # write file
        File.delete absolute_filepath if File.exist? absolute_filepath
        file = File.new(absolute_filepath, File::CREAT | File::RDWR, 777)
        file.write(data)
        file.close
      end

      protected

      def relative_filepath
        raise NotImplementedError
      end

      def base_directory
        raise NotImplementedError
      end

      def data
        raise NotImplementedError
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

      def relative_filepath
        @resource.relative_filepath ||= File.join @resource.uri.host, @resource.uri.path, 'index.html'
      end

      def base_directory
        @resource.base_directory ||= Dir.getwd
      end

      def data
        @resource.response.body
      end
    end

    class StoreResponseImage < Fetch::Service::StoreResponse
      private

      def before_process
      end
      
      def relative_filepath
        @resource.uri.path
      end

      def base_directory
        @resource.base_directory
      end

      def data
        @resource.response.body
      end
    end

    # StoreResponseImages is to store any images that is already loaded
    class StoreResponseImages < Fetch::Service::Base
      def before_process
      end

      def process
        image_base_directtory = File.join @resource.base_directory, File.split(@resource.relative_filepath).first
        @resource.images_content.each do |image_path, image_resource|
          image_resource.base_directory = image_base_directtory
          Fetch::Service::StoreResponseImage.new(image_resource).process
        end
      end
    end
  end
end
