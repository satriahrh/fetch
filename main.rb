# frozen_string_literal: true

require './lib/lib'

Fetch::Error.exit_with_message 'No url(s) supplied' if
  ARGV.empty?

uris = ARGV[0] == '--metadata' ? ARGV[1..] : ARGV

Fetch::Error.exit_with_message 'No url(s) supplied' if
  uris.empty?

resources = []
uris.each do |uri|
  resource = Fetch::Model::Resource.new uri
  resources << resource
rescue Fetch::Error::ResourceInvalidURI => e
  Fetch::Error.exit_with_message "Invalid uri for \"#{uri}\", #{e.message}"
end

services = if ARGV[0] == '--metadata'
             [
               Fetch::Service::LoadHTMLFromCache
             ]
           else
             [
               Fetch::Service::LoadHTMLFromServer,
               Fetch::Service::LoadAndStoreImages,
               Fetch::Service::StoreResponse
             ]
           end

wg = Fetch::Helper::WaitGroup.new
resources.each do |resource|
  Thread.new do
    wg.add 1
    services.each do |service|
      service_with_resource = service.new(resource)
      resource = service_with_resource.run
    end
    puts "#{resource.uri}\n" \
      + "\tcache file path\t\t: #{File.join resource.base_directory, resource.relative_filepath}\n" \
      + "\tnumber of links\t\t: #{resource.metadata['num_links']}\n" \
      + "\tnumber of images\t: #{resource.metadata['num_images']}\n" \
      + "\tlast fetch\t\t: #{resource.metadata['last_fetch']}\n"
  ensure
    wg.done
  end.run
end

wg.wait
