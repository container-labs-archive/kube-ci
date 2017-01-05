class Deployer
  def initialize
    @client = SlackNotify::Client.new(
      webhook_url: ENV['SLACK_WEBHOOK_URL'],
      channel: "#in-app-marketing",
      username: "kube-deploy"
    )
  end

  def process_request(request_params, dry_run = false)
    app = request_params[:app]
    environment = request_params[:environment]
    image = request_params[:image_path]

    result = deploy_app(environment, app, image, dry_run).merge(dry_run: dry_run)

    # log the deployment
    # TODO: persist this
    STDERR.puts Oj.dump(result)

    result
  end

  private

  def patch_request(environment, app, new_image)
    auth = { username: ENV['KUBE_CLUSTER_USERNAME'], password: ENV['KUBE_CLUSTER_PASSWORD'] }
    headers = {}
    headers['Content-Type'] = 'application/json-patch+json'
    path = "https://#{ENV['KUBE_CLUSER_IP']}/apis/extensions/v1beta1/namespaces/#{environment}/deployments/#{app}"
    STDERR.puts "PATCH: #{path}"

    # TODO: add support for more than 1 container per deployment
    patch_body = [{ op: 'replace', path: '/spec/template/spec/containers/0/image',  value: new_image }]
    STDERR.puts "PATCH-BODY: #{patch_body}"
    response = HTTParty.patch(path,
                   body: Oj.dump(patch_body),
                   headers: headers,
                   basic_auth: auth)

    response
  end

  def generate_metadata(environment, app, version)
    # TODO: deployed by
    {
      app: app,
      deployed_at: Time.now.strftime("%y-%m-%d_%h:%m:%s"),
      environment: environment,
      version: version
    }
  end

  def deploy_app(environment, app, version, dry_run = false)
    metadata = generate_metadata(environment, app, version)

    return metadata if dry_run

    response = patch_request(environment, app, metadata[:version])

    if ENV['POST_TO_SLACK'] == 'true'
      @client.notify("deployed version: #{version.split(":")[-1]} of #{app} to #{environment}")
    end

    metadata[:apiResponse] = response
    metadata
  end
end
