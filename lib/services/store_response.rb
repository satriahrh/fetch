# frozen_string_literal: true

module Fetch
  module Service
    # StoreResponse is base class of storing/caching
    # a http response to file
    class StoreResponse < Fetch::Service::Base
      def before_process
        raise 'response body is empty' unless
          @resource.content
      end

      def process
        relative_dirname, filename = File.split @resource.relative_filepath
        base_relative_directory = @resource.base_directory
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

      def data
        @resource.content.to_html
      end
    end
  end
end
