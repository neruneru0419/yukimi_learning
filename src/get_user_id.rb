require_relative "request"

module GetUserId  
  def get_user_id(format: "json")#"tweet_ids" must be a string. If more than one ID's are given, they must be comma separated
    url = "https://api.twitter.com/2/users/by?usernames=Nerun_neruneru"

    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }
    oauth1_request(url, options)
  end
end
