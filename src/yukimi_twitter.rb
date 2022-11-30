require "typhoeus"
require "json"
require "oauth"

require_relative "twitter/get_timeline"
require_relative "twitter/get_tweet"
require_relative "twitter/get_user_id"
require_relative "twitter/get_user_timeline"
require_relative "twitter/get_mention"
require_relative "twitter/get_users"
require_relative "twitter/post_tweet"
require_relative "twitter/post_favorite"
require_relative "twitter/post_reply"
require_relative "twitter/delete_remove"

module YukimiTwitter
  include GetTimeline
  include GetTweet
  include GetUserTimeline
  include GetUserId
  include GetMention
  include GetUsers
  include PostTweet
  include PostFavorite
  include PostReply
  include DeleteRemove
end
