module Fetch
  module Service
    class Base
      def initialize resource
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