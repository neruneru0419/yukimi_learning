module GetUserTweet
  def get_user_tweet(tweet_ids, format: "json")
    query = {
      "ids" => tweet_ids,
      "tweet.fields" => "conversation_id,created_at,public_metrics,id,referenced_tweets",
      "media.fields" => "url",
      "user.fields" => "description,username,url",
      "expansions" => "author_id"            
    }

    url = "https://api.twitter.com/2/tweets?#{URI.encode_www_form(query)}"

    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }
    oauth1_request(url, options)
  end
end
