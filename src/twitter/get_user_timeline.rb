module GetUserTimeline
  def get_user_timeline(user_id, format: "json")
    query = {
      "tweet.fields" => "conversation_id,created_at,public_metrics,id,referenced_tweets",
      "media.fields" => "url",
      "user.fields" => "description,username,url",
      "expansions" => "author_id,in_reply_to_user_id",
      "exclude" => "retweets,replies",
  }
    url = "https://api.twitter.com/2/users/#{user_id}/tweets?max_results=100&#{URI.encode_www_form(query)}"

    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }
    oauth1_request(url, options)
  end
end
