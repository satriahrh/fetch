# frozen_string_literal: true

require 'base64'
require 'net/http'
require 'nokogiri'
require 'uri'

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
        @resource.metadata[:num_images] = @imgs.length
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
        @resource.metadata[:num_links] = @links.length
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
        @resource.metadata[:last_fetch] = Time.now
      end
    end

    class LoadHTMLFromCache < Fetch::Service::LoadHTML
      def before_process
        raise 'no filepath' unless
          @resource.base_directory && @resource.relative_filepath
      end

      def process
        filepath = File.join(@resource.base_directory, @resource.relative_filepath)
        File.open filepath, 'r' do |file|
          @resource.content = file.read
          @resource.metadata[:last_fetch] = file.birthtime
        end
      end
    end

    class LoadImages < Fetch::Service::Base
      def before_process
        raise 'resource should be an instance of Fetch::Model::Resource' unless
          [URI::HTTPS, URI::HTTP].include? @resource&.uri.class
      end

      def process
        @resource.content.search('img').each do |image|
          next if data_uri?(image['src]'])

          image_uri = image['src']
          unless URI::DEFAULT_PARSER.make_regexp(%w[http https]).match? image_uri
            image_uri = URI.join("#{@resource.uri.scheme}://#{@resource.uri.host}", image_uri)
          else
            image_uri = URI.parse image_uri
          end

          image_content = Net::HTTP.get_response(image_uri)
          image['src'] = "data:#{image_content.content_type};base64,#{Base64.strict_encode64(image_content.body)}"
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
