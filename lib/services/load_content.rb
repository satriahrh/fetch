# frozen_string_literal: true

require 'base64'
require 'concurrent'
require 'net/http'
require 'nokogiri'
require 'uri'
require 'json'

module Fetch
  module Service
    class LoadHTML < Fetch::Service::Base
      def after_process
        parse_html
        collect_images
        collect_links
      end

      private

      def parse_html
        @resource.content = Nokogiri::HTML(@resource.content)
      end

      def collect_images
        @doc_imgs = @resource.content.search 'img'
        @imgs = {}
        @doc_imgs.each do |doc_img|
          src = doc_img['src']

          @imgs[src] = 0 unless @imgs[src]
          @imgs[src] += 1
        end
        @resource.images = @doc_imgs
        @resource.metadata["num_images"] = @imgs.length
      end

      def collect_links
        @doc_links = @resource.content.search 'a'
        @links = {}
        @doc_links.each do |doc_link|
          href = doc_link['href']
          next unless href

          @links[href] = 0 unless @links[href]
          @links[href] += 1
        end

        @resource.links = @doc_links
        @resource.metadata["num_links"] = @links.length
      end
    end

    # LoadHTMLFromServer is to fetch the content from given URI
    class LoadHTMLFromServer < Fetch::Service::LoadHTML
      def before_process
        raise 'resource should be an instance of Fetch::Model::Resource' unless
          [URI::HTTPS, URI::HTTP].include? @resource&.uri.class
      end

      def process
        uri = @resource.uri
        @resp = Net::HTTP.get_response(uri)

        raise 'Get not OK response from given url' unless
          @resp.instance_of? Net::HTTPOK

        @resource.content = @resp.body
        @resource.metadata["last_fetch"] = Time.now
      end
    end

    class LoadHTMLFromCache < Fetch::Service::LoadHTML
      def before_process
        raise 'no filepath' unless
          @resource.base_directory && @resource.relative_filepath
      end

      def process
        html_filepath = File.join(@resource.base_directory, @resource.relative_filepath)
        File.open html_filepath, 'r' do |file|
          @resource.content = file.read
        end

        meta_dir, _ = File.split html_filepath
        meta_filepath = File.join meta_dir, 'meta.json'
        @resource.metadata = JSON.load_file(meta_filepath)
      end
    end

    class LoadImages < Fetch::Service::Base
      def before_process
        raise 'resource should be an instance of Fetch::Model::Resource' unless
          [URI::HTTPS, URI::HTTP].include? @resource&.uri.class
      end

      def process
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
            image['src'] = "data:#{image_content.content_type};base64,#{Base64.strict_encode64(image_content.body)}"
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
