require "typhoeus"
require "json"
require "oauth"
require "byebug"

require_relative "twitter/yukimi_twitter"
require_relative "parser/parser"


def tweet
  include YukimiTwitter
  include Parser

  user_id = get_user_id(UserName)["data"][0]["id"]
  timeline_data = get_timeline_data(user_id)

  tweet_text = timeline_data["text"]
  tweet_id = timeline_data["id"]
  yukimi_text = change_yukimi(tweet_text)

  post_tweet(yukimi_text)
  post_favorite(user_id, tweet_id)
end

def get_timeline_data(user_id)
  timeline_data = get_home_timeline(user_id)["data"].sample
  timeline_text = timeline_data["text"]
  if timeline_text.include?("http") || timeline_text.include?("#")
    get_timeline_data(user_id)
  else
    timeline_data 
  end
end
tweet