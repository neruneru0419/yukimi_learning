require "typhoeus"
require "json"
require "oauth"

require_relative "delete_remove"
require_relative "get_follower_id"
require_relative "get_followee_id"
require_relative "get_home_timeline"
require_relative "get_mention"
require_relative "get_user_id"
require_relative "get_user_timeline"
require_relative "get_user_tweet"
require_relative "post_favorite"
require_relative "post_reply"
require_relative "post_tweet"

module YukimiTwitter
  include DeleteRemove
  include GetFolloweeId
  include GetFollowerId
  include GetHomeTimeline
  include GetMention
  include GetUserId
  include GetUserTimeline
  include GetUserTweet
  include PostFavorite
  include PostReply
  include PostTweet

  UserName = "runeru_runerune"
end
