require "typhoeus"
require "json"
require "oauth"
require 'oauth/request_proxy/typhoeus_request'

module Request
  def oauth1_request(url, options)
    api_key = ENV["api_key"]
    api_key_secret = ENV["api_key_secret"]
    access_token = ENV["access_token"]
    access_token_secret = ENV["access_token_secret"]
    client = OAuth::Consumer.new(api_key, api_key_secret, :site => 'https://api.twitter.com',
                                                          :authorize_path => '/oauth/authenticate',
                                                          :debug_output => false)
    credentials = OAuth::AccessToken.new(client, access_token, access_token_secret)

    access_token = credentials
    oauth_params = {:consumer => client, :token => access_token}
  
    request = Typhoeus::Request.new(url, options)
    oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => url))
    request.options[:headers].merge!({"Authorization" => oauth_helper.header})
    response = request.run
  
    return JSON.parse(response.body)
  end
end
