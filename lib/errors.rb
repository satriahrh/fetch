module Fetch
  module Error
    class Standard < StandardError
    end

    class ResourceInvalidURI < Standard
      def message
        'only http and https schema are allowed'
      end
    end
  end
end