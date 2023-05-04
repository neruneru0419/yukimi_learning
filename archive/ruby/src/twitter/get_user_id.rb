require 'uri'
require_relative "request"

module GetUserId  
  def get_user_id(username, format: "json")#"tweet_ids" must be a string. If more than one ID's are given, they must be comma separated
    query = {
      "usernames": username
    }
    url = "https://api.twitter.com/2/users/by?#{URI.encode_www_form(query)}"

    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }
    oauth1_request(url, options)
  end
end
