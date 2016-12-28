require 'optparse'

require_relative 'pusher'

options = {
}
OptionParser.new do |opts|
  opts.banner = 'Usage: docker-compose run image-pusher [options]'

  ##################
  # pusher options #
  opts.on('-b', '--build-directory=REQUIRED', 'Build directory') do |v|
    options[:build_directory] = v
  end

  opts.on('-i', '--image-name=REQUIRED', 'Image name') do |v|
    options[:image_name] = v
  end

  opts.on('-t', '--image-tag=REQUIRED', 'Image name') do |v|
    options[:image_tag] = v
  end

  opts.on('-r', '--registry-url=REQUIRED', 'Registry url') do |v|
    options[:registry_url] = v
  end
end.parse!

raise OptionParser::MissingArgument.new('--image-name') if options[:image_name].nil?
raise OptionParser::MissingArgument.new('--image-tag') if options[:image_tag].nil?
raise OptionParser::MissingArgument.new('--registry-url') if options[:registry_url].nil?

pusher = Pusher.new(options)
image_path = pusher.generate_commands
