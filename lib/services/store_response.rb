module Fetch
  module Service
    class StoreResponse < Fetch::Service::Base
      def process
        split_directory_from_resource_uri
        create_base_directory
        create_filepath
        store_to_filepath
      end

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
          unless Dir.exist? @resource.base_directory
            Dir.mkdir @resource.base_directory
          end
        end
      end

      def create_filepath
        @resource.filename = filename
        @filepath = File.join @resource.base_directory, @resource.filename
      end

      def store_to_filepath
        if File.exist? @filepath
          File.delete @filepath
        end
        file = File.new(@filepath, File::CREAT|File::RDWR, 777)
        file.write(@resource.response.body)
        file.close
      end
    end

    class StoreResponseHtml < Fetch::Service::StoreResponse
      def filename
        'index.html'
      end
    end
  end
end