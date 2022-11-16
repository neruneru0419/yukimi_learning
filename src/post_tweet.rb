require_relative "request"

module PostTweet
  include Request
  def post_tweet(text)

    url = "https://api.twitter.com/2/tweets"

    @json_payload = {
      "text": text
    }

    {"text": "Excited!", "reply": {"in_reply_to_tweet_id": "1455953449422516226"}}
    options = {
      :method => :post,
      headers: {
            "content-type": "application/json"
      },
      body: JSON.dump(@json_payload)
    }
    oauth1_request(url, options)
  end
end
