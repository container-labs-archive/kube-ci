require 'httparty'
require 'optparse'
require 'uri'

require_relative 'client'

options = {
  environment: 'default',
  deployer_ip: 'localhost:4567'
}
OptionParser.new do |opts|
  opts.banner = 'Usage: docker-compose run kube-ci [options]'

  opts.on('-n', '--app-name=REQUIRED', 'App name') do |v|
    options[:app_name] = v
  end

  opts.on('-i', '--image-name=REQUIRED', 'Image name') do |v|
    options[:image_name] = v
  end

  opts.on('-t', '--image-tag=REQUIRED', 'Image tag') do |v|
    options[:image_tag] = v
  end

  opts.on('-d', '--deployer-ip=REQUIRED', 'IP of deploy service') do |v|
    options[:deployer_ip] = v
  end

  opts.on('-e', '--environment', 'environment') do |v|
    options[:environment] = v
  end

  opts.on('-p', '--password=REQUIRED', 'Password to authenticate with deploy service') do |v|
    options[:password] = v
  end

  opts.on('-u', '--username=REQUIRED', 'Username to authenticate with deploy service') do |v|
    options[:username] = v
  end

  opts.on('-r', '--registry-url=REQUIRED', 'Registry url') do |v|
    options[:registry_url] = v
  end
end.parse!


raise OptionParser::MissingArgument.new('--app-name') if options[:app_name].nil?
raise OptionParser::MissingArgument.new('--image-name') if options[:image_name].nil?
raise OptionParser::MissingArgument.new('--image-tag') if options[:image_tag].nil?
raise OptionParser::MissingArgument.new('--registry-url') if options[:registry_url].nil?
raise OptionParser::MissingArgument.new('--password') if options[:password].nil?
raise OptionParser::MissingArgument.new('--username') if options[:username].nil?


client = DeployClient.new(options)
client.deploy
