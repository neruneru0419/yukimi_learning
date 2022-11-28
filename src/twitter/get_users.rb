require 'uri'
require_relative "request"

module GetUsers
  def get_users(user_ids, format: "json")
    user_ids = "2244994945,783214"
    query = {
      "ids": user_ids,
      "expansions": "pinned_tweet_id",
      "tweet.fields": "attachments,author_id,conversation_id,created_at,entities,geo,id,in_reply_to_user_id,lang",
    }

    
    url = "https://api.twitter.com/2/users?#{URI.encode_www_form(query)}"

    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }
    oauth1_request(url, options)
  end
end
