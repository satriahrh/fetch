require './lib/lib.rb'

if ARGV.length == 0
  Fetch::Error.exit_with_message "No url(s) supplied"
end

resources = []
ARGV.each do |uri|
  begin
    resource = Fetch::Model::Resource.new uri
    resources << resource
  rescue Fetch::Error::ResourceInvalidURI => e
    Fetch::Error.exit_with_message "Invalid uri for \"#{uri}\", #{e.message}"
  end
end

services = [
  Fetch::Service::LoadContent,
  Fetch::Service::StoreResponseHtml
]

resources.each do |resource|
  services.each do |service|
    service_with_resource = service.new(resource)
    service_with_resource.process
    resource = service_with_resource.result
  end
  puts "Webpage #{resource.uri.host}/#{resource.uri.path}\n\tcan be accessed from #{File.join resource.base_directory, resource.filename}"
end
