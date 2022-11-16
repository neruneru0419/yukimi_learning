require_relative "request"

module DeleteRemove
  include Request
  def delete_remove(user_id, target_user_id)

    url = "https://api.twitter.com/2/users/#{user_id}/following/#{target_user_id}"

    options = {
      :method => :delete,
      headers: {
            "content-type": "application/json"
      }
    }
    oauth1_request(url, options)
  end
end
