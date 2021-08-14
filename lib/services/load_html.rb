# frozen_string_literal: true

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
        @resource.metadata['num_images'] = @imgs.length
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
        @resource.metadata['num_links'] = @links.length
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
        @resource.metadata['last_fetch'] = Time.now
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

        meta_dir, = File.split html_filepath
        meta_filepath = File.join meta_dir, 'meta.json'
        @resource.metadata = JSON.load_file(meta_filepath)
      end
    end
  end
end
