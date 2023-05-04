
module GetHomeTimeline    
  def get_home_timeline(user_id, format: "json")#"tweet_ids" must be a string. If more than one ID's are given, they must be comma separated
    query = {
      "tweet.fields" => "conversation_id,created_at,public_metrics,id,referenced_tweets,reply_settings",
      "user.fields" => "description,username,url",
      "expansions" => "author_id",
      "exclude" => "retweets,replies",
    }
    url = "https://api.twitter.com/2/users/#{user_id}/timelines/reverse_chronological?#{URI.encode_www_form(query)}"

    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }

    oauth1_request(url, options)
  end
end
