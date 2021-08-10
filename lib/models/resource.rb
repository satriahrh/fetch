require 'uri'

module Fetch
  module Model
    class Resource
      attr_accessor :uri
    
      def initialize(full_url)
        self.uri = full_url
      end
    
    
      def uri= new_value
        @uri = URI.parse new_value
        unless [URI::HTTPS, URI::HTTP].include? @uri.class
          raise Fetch::Error::ResourceInvalidURI
        end
      end
    
      def to_s
        "Resource of #{@uri}"
      end
    end    
  end
end
