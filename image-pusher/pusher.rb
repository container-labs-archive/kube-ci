require 'time'

class Pusher
  def initialize(opts = {})
    @build_directory = opts[:build_directory] || ''
    @registry_url = opts[:registry_url]
    @image_name = opts[:image_name]
    @image_tag = opts[:image_tag]
  end

  def generate_commands
    @build_timestamp = Time.now.strftime("%y-%m-%d_%H-%M-%S")

    # auth is before build so we can dowload any base images in the private registry
    # during the build phase
    authenticate
    build
    tag
    push
  end

  private

  # TODO: add authenticate for other registries
  def authenticate
    print 'docker pull containerlabs/aws-sdk:latest ; '
    print 'eval $(docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY containerlabs/aws-sdk aws ecr get-login --region us-east-1) ; '
  end

  def build
    print "docker build -t #{@image_name} ./#{@build_directory} ; "
  end

  def tag
    print "docker tag #{@image_name}:latest #{@registry_url}/#{@image_name}:#{@image_tag} ; "
  end

  def push
    print "docker push #{@registry_url}/#{@image_name}:#{@image_tag} "
  end
end
