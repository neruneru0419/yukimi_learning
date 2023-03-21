module GetMention
  def get_mention(user_id, format: "json")#"tweet_ids" must be a string. If more than one ID's are given, they must be comma separated
    query = {
      "tweet.fields" => "attachments,author_id,conversation_id,created_at,entities,id,lang,referenced_tweets",
      "user.fields" => "description",
      "expansions" => "attachments.poll_ids,attachments.media_keys,author_id,in_reply_to_user_id",
      "max_results" => "100"
    }
    url = "https://api.twitter.com/2/users/#{user_id}/mentions?&#{URI.encode_www_form(query)}"
    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }

    oauth1_request(url, options)
  end
end
