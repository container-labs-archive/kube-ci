require 'httparty'

class DeployClient
  def initialize(opts = {})
    @app_name = opts[:app_name]
    @deployer_ip = opts[:deployer_ip]
    @environment = opts[:environment]
    @image_tag = opts[:image_tag]
    @image_name = opts[:image_name]
    @username = opts[:username]
    @password = opts[:password]
    @registry_url = opts[:registry_url]
  end

  def deploy
    image_path = "#{@registry_url}/#{@image_name}:#{@image_tag}"

    path = "https://#{@deployer_ip}/deploy/#{@environment}/#{@app_name}"
    auth = { username: @username, password: @password }

    STDERR.puts "POST: #{path}"
    response = HTTParty.post(path, basic_auth: auth, body: { image_path: image_path }.to_json )

    STDERR.puts response
  end
end
