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

puts resources
