# frozen_string_literal: true

require './lib/lib'

Fetch::Error.exit_with_message 'No url(s) supplied' if
  ARGV.empty?

resources = []
ARGV.each do |uri|
  resource = Fetch::Model::Resource.new uri
  resources << resource
rescue Fetch::Error::ResourceInvalidURI => e
  Fetch::Error.exit_with_message "Invalid uri for \"#{uri}\", #{e.message}"
end

services = [
  Fetch::Service::LoadContent,
  Fetch::Service::StoreResponseHtml,
  Fetch::Service::ParseHTML
]

resources.each do |resource|
  services.each do |service|
    service_with_resource = service.new(resource)
    resource = service_with_resource.run
  end
  puts "Webpage #{resource.uri}\n" \
    + "\tcan be accessed from #{File.join resource.base_directory, resource.filename}\n" \
    + "\ttotal images: #{resource.images.keys.length}\n" \
    + "\ttotal links: #{resource.links.keys.length}"
end
