require "typhoeus"
require "json"
require "oauth"

require_relative "twitter/get_timeline"
require_relative "twitter/get_tweet"
require_relative "twitter/get_user_id"
require_relative "twitter/get_mention"
require_relative "twitter/get_users"
require_relative "twitter/post_tweet"
require_relative "twitter/post_favorite"
require_relative "twitter/post_reply"
require_relative "twitter/delete_remove"

module YukimiTwitter
  class Twitter
    include GetTimeline
    include GetTweet
    include GetUserId
    include GetMention
    include GetUsers
    include PostTweet
    include PostFavorite
    include PostReply
    include DeleteRemove

    def initialize
      @api_key = ENV["api_key"]
      @api_key_secret = ENV["api_key_secret"]
      @access_token = ENV["access_token"]
      @access_token_secret = ENV["access_token_secret"]
      @bearer_token = ENV["bearer_token"]
      @client = OAuth::Consumer.new(@api_key, @api_key_secret, :site => 'https://api.twitter.com',
                                                            :authorize_path => '/oauth/authenticate',
                                                            :debug_output => false)
      @credentials = OAuth::AccessToken.new(@client, @access_token, @access_token_secret)
    end
  end
end
