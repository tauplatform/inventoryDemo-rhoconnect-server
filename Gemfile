source 'http://rubygems.org'

ruby "~> 2.6.3"

gem 'rhoconnect', '>= 7.1.17'
gem 'aws-sdk-s3', '~> 1.36'

gemfile_path = File.join(File.dirname(__FILE__), ".rcgemfile")
begin
  eval(IO.read(gemfile_path))
rescue Exception => e
  puts "ERROR: Couldn't read RhoConnect .rcgemfile"
  exit 1
end

# Add your application specific gems after this line ...
