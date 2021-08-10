if ARGV.length == 0
  throw 'no url(s) supplied'
end

require './lib/lib.rb'

resources = []
ARGV.each do |uri|
  begin
    resource = Fetch::Model::Resource.new uri
    resources << resource
  rescue Fetch::Error::ResourceInvalidURI => e
    puts "ERROR: Invalid uri for \"#{uri}\", #{e.message}"
    exit 1
  end
end

puts resources
