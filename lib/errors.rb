# frozen_string_literal: true

module Fetch
  # Error consists of defined error in project level.
  module Error
    class Standard < StandardError
    end

    # ResourceInvalidURI is used when Fetch::Model::Resource.new
    # failed to parse the given uri
    class ResourceInvalidURI < Standard
      def message
        'only http and https schema are allowed'
      end
    end

    def exit_with_message(str)
      puts "ERROR: #{str}"
      exit 1
    end

    module_function :exit_with_message
  end
end
