module GetFolloweeId
  def get_followee_id(user_id, format: "json")
    url = "https://api.twitter.com/2/users/#{user_id}/following"

    options = {
      :method => :get,
      headers: {
            "content-type": "application/json"
      }
    }
    oauth1_request(url, options)
  end
end