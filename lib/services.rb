# frozen_string_literal: true

module Fetch
  module Service
    # Base
    class Base
      def initialize(resource)
        @resource = resource
      end

      def run
        process
        @resource
      end

      protected

      def process
        raise NotImplementedError
      end
    end
  end
end

Dir['./lib/services/*'].each { |file| require file }
