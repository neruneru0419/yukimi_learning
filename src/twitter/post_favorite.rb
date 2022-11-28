require_relative "request"

module PostFavorite
  include Request
  def post_favorite(user_id, tweet_id)

    url = "https://api.twitter.com/2/users/#{user_id}/likes"

    @json_payload = {"tweet_id": tweet_id}

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
