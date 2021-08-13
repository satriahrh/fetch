# frozen_string_literal: true

require 'nokogiri'

module Fetch
  module Service
    # ParseHTML is to parse response body
    class ParseHTML < Fetch::Service::Base
      def before_process
        content_type = @resource&.response&.content_type
        raise "response content-type is not html, found #{content}" unless
           content_type == 'text/html'
      end

      def process
        parse_html
        collect_images
        collect_links
      end

      def after_process
        @resource.images = @imgs
        @resource.links = @links
      end

      private

      def parse_html
        @doc_html = Nokogiri::HTML(@resource.response.body)
      end

      def collect_images
        @doc_imgs = @doc_html.search 'img'
        @imgs = {}
        @doc_imgs.each do |doc_img|
          src = doc_img['src']
          next unless a_path? src

          @imgs[src] = 0 unless @imgs[src]
          @imgs[src] += 1
        end
      end

      def collect_links
        @doc_links = @doc_html.search 'a'
        @links = {}
        @doc_links.each do |doc_link|
          href = doc_link['href']
          next unless href

          @links[href] = 0 unless @links[href]
          @links[href] += 1
        end
      end

      def a_path?(src)
        return false unless src && !src.empty?

        # due to https://gist.github.com/khanzadimahdi/bab8a3416bdb764b9eda5b38b35735b8
        data_uri_schema_regex = %r{^data:((?:\w+/(?:(?!;).)+)?)((?:;[\w\W]*?[^;])*),(.+)$}
        return false if
          src.match data_uri_schema_regex

        true
      end
    end
  end
end
