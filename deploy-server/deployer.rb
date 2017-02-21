class Deployer
  def initialize
    @slack_client = SlackNotify::Client.new(
      webhook_url: ENV['SLACK_WEBHOOK_URL'],
      channel: "#in-app-marketing",
      username: "kube-deploy"
    )

    if ENV['ES_CLIENT_URL']
      @es_client = Elasticsearch::Client.new log: true, host: ENV['ES_CLIENT_URL']
    end
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
    auth = nil
    headers = {}
    headers['Content-Type'] = 'application/json-patch+json'

    if ENV['SERVICE_ACCOUNT_TOKEN']
      headers['Authorization'] = "Bearer #{ENV['SERVICE_ACCOUNT_TOKEN']}"
    else
      auth = { username: ENV['KUBE_CLUSTER_USERNAME'], password: ENV['KUBE_CLUSTER_PASSWORD'] }
    end

    path = "https://#{ENV['KUBE_CLUSER_IP']}/apis/extensions/v1beta1/namespaces/#{environment}/deployments/#{app}"
    STDERR.puts "PATCH: #{path}"

    # TODO: add support for more than 1 container per deployment
    patch_body = [{ op: 'replace', path: '/spec/template/spec/containers/0/image',  value: new_image }]
    STDERR.puts "PATCH-BODY: #{patch_body}"

    if auth
      response = HTTParty.patch(path,
                     body: Oj.dump(patch_body),
                     headers: headers,
                     basic_auth: auth)
    else
      response = HTTParty.patch(path,
                     body: Oj.dump(patch_body),
                     headers: headers,
                     # don't verify SSL cert...
                     verify: false)
    end

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

    version_sha = version.split(":")[-1]

    if ENV['POST_TO_SLACK'] == 'true'
      @slack_client.notify("deployed version: #{version_sha} of #{app} to #{environment}")
    end

    if ENV['ES_LOG_DEPLOY'] == 'true'
      @es_client.index  index: ENV['ES_INDEX'], type: 'deploy', id: SecureRandom.uuid, body: { '@timestamp' => Time.now.utc.to_i * 1000, tags: "deploy #{app} #{environment}", title: "#{app} deploy", text: "Deployed #{version_sha}" }
    end

    # TODO: this makes kibanna noisy, bring back later
    # metadata[:apiResponse] = response
    STDERR.puts response
    metadata
  end
end
