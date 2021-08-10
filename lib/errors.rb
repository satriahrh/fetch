module Fetch
  module Error
    class Standard < StandardError
    end

    class ResourceInvalidURI < Standard
      def message
        'only http and https schema are allowed'
      end
    end

    def exit_with_message str
      puts "ERROR: #{str}"
      exit 1
    end

    module_function :exit_with_message
  end
end