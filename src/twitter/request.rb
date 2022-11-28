require "typhoeus"
require "json"
require "oauth"
require 'oauth/request_proxy/typhoeus_request'

module Request
  def oauth1_request(url, options)
    access_token = @credentials

    oauth_params = {:consumer => @client, :token => access_token}
  
    request = Typhoeus::Request.new(url, options)
    oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => url))
    request.options[:headers].merge!({"Authorization" => oauth_helper.header})
    response = request.run
  
    return JSON.parse(response.body)
  end
end
