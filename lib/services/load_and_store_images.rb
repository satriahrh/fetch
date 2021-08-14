# frozen_string_literal: true

module Fetch
  module Service
    class LoadAndStoreImages < Fetch::Service::Base
      def before_process
        raise 'resource should be an instance of Fetch::Model::Resource' unless
          [URI::HTTPS, URI::HTTP].include? @resource&.uri.class
      end

      def process
        relative_basedir, = File.split @resource.relative_filepath
        wg = Fetch::Helper::WaitGroup.new
        @resource.content.search('img').each do |image|
          next if data_uri?(image['src]'])

          image_uri = image['src']
          image_uri = if URI::DEFAULT_PARSER.make_regexp(%w[http https]).match? image_uri
                        URI.parse image_uri
                      else
                        URI.join("#{@resource.uri.scheme}://#{@resource.uri.host}", image_uri)
                      end

          Thread.new do
            wg.add 1
            image_content = Net::HTTP.get_response(image_uri)
            relative_filepath = File.join(relative_basedir, image_uri.host, image_uri.path)
            Fetch::Helper::StoreToFile.new(
              relative_filepath,
              image_content.body,
              @resource.base_directory
            )
            image['src'] = File.join image_uri.host, image_uri.path
          ensure
            wg.done
          end.run
        end
        wg.wait
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
