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
  Fetch::Service::LoadHTML,
  Fetch::Service::StoreResponseHtml,
  Fetch::Service::ParseHTML,
  Fetch::Service::LoadImages,
  Fetch::Service::StoreResponseImages
]

resources.each do |resource|
  services.each do |service|
    service_with_resource = service.new(resource)
    resource = service_with_resource.run
  end
  puts "#{resource.uri}\n" \
    + "\tcache file path\t\t: #{File.join resource.base_directory, resource.relative_filepath}\n" \
    + "\tnumber of links\t\t: #{resource.metadata[:num_links]}\n" \
    + "\tnumber of images\t: #{resource.metadata[:num_images]}\n" \
    + "\tlast fetch\t\t: #{resource.metadata[:last_fetch]}\n"
end
