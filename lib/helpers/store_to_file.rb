# frozen_string_literal: true

module Fetch
  module Helper
    class StoreToFile
      def initialize(relative_path, data, base_dir = Dir.getwd)
        @data = data
        @relative_filepath = relative_path
        @base_dir = base_dir
        store
      end

      private

      def store
        relative_dir, filename = File.split @relative_filepath
        absolute_dir = @base_dir
        relative_dir.split('/').each do |dir|
          absolute_dir = File.join absolute_dir, dir
          Dir.mkdir absolute_dir
        rescue Errno::EEXIST
          next
        end

        absolute_filepath = File.join absolute_dir, filename

        File.open absolute_filepath, 'w+' do |file|
          file.flock File::LOCK_EX
          file.write @data
        end
      end
    end
  end
end
