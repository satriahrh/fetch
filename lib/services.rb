# frozen_string_literal: true

module Fetch
  module Service
    # Base
    class Base
      def initialize(resource)
        @resource = resource
      end

      def process
        raise NotImplementedError
      end

      def result
        @resource
      end
    end
  end
end

Dir['./lib/services/*'].each { |file| require file }
