module GetFollowerId
  def get_follower_id(user_id, format: "json")
    url = "https://api.twitter.com/2/users/#{user_id}/followers"

    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }
    oauth1_request(url, options)
  end
end