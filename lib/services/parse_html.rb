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
        @resource.metadata[:num_links] = @links.length
        @resource.metadata[:num_images] = @imgs.length
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
    end
  end
end
