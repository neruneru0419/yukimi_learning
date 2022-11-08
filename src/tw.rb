class User
  include GetUserTimeline
  include GetTweets
  include GetUser
  include GetFollow
  include PostDeleteTweets

  def initialize(api_key, api_key_secret, access_token, access_token_secret, bearer_token)
      @api_key = api_key
      @api_key_secret = api_key_secret
      @access_token = access_token
      @access_token_secret = access_token_secret
      @bearer_token = bearer_token
  end
end