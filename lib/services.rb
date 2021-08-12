# frozen_string_literal: true

module Fetch
  module Service
    # Base
    class Base
      def initialize(resource)
        raise "resource should be an instance of Fetch::Model::Resource, but found #{resource.class}" unless
          resource.instance_of? Fetch::Model::Resource

        @resource = resource
      end

      def run
        before_process
        process
        after_process
        @resource
      end

      protected

      def before_process
        raise NotImplementedError
      end

      def process
        raise NotImplementedError
      end

      def after_process
      end
    end
  end
end

Dir['./lib/services/*'].each { |file| require file }
