require 'httparty'
require 'oj'
require 'sinatra'
require 'yaml'

require_relative 'deployer'

Oj.default_options = { mode: :compat }
set :bind, '0.0.0.0'

# TODO: use vars
use Rack::Auth::Basic, 'Must be authorized' do |username, password|
  username == 'admin' and password == 'admin'
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
post '/deploy/:environment/:app/:image' do
  content_type :json
  deployer = Deployer.new
  Oj.dump(deployer.process_request(params))
end
