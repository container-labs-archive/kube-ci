require 'httparty'
require 'oj'
require 'sinatra'
require 'yaml'
require 'slack-notify'

require_relative 'deployer'

Oj.default_options = { mode: :compat }
set :bind, '0.0.0.0'

use Rack::Auth::Basic, 'Must be authorized' do |username, password|
  username == ENV['DEPLOY_USERNAME'] and password == ENV['DEPLOY_PASSWORD']
end

get '/' do
  'welcome to kube-deployer'
end

get '/deploy/:environment/:app/:image' do
  content_type :json
  deployer = Deployer.new
  Oj.dump(deployer.process_request(params, true))
end

# TODO: notify slack, hipchat
post '/deploy/:environment/:app' do
  content_type :json
  deployer = Deployer.new
  data = JSON.parse(request.body.read.to_s)
  Oj.dump(deployer.process_request(params.merge(data)))
end
