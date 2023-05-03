require "typhoeus"
require "json"
require "oauth"
require "byebug"

require_relative "twitter/yukimi_twitter"
require_relative "parser/parser"
require_relative "ngword/ngword"

include YukimiTwitter
include Parser
include Ngword

module LambdaFunction
  class Handler
    def self.process(event:, context:)
      user_id = get_user_id(UserName)["data"][0]["id"]
      timeline_data = get_timeline_data(user_id)
      puts timeline_data
      tweet_text = timeline_data["text"]
      tweet_id = timeline_data["id"]
      yukimi_text = change_yukimi(tweet_text)

      post_tweet(yukimi_text)
      post_favorite(user_id, tweet_id)
    end
  end
end

def get_timeline_data(user_id)
  timeline_data = get_home_timeline(user_id)["data"].sample
  timeline_text = timeline_data["text"]
  unless timeline_text.include?("http") || timeline_text.include?("#") || timeline_text.include?("@") \
          || ngword?(timeline_text) || timeline_data["author_id"] == user_id
    timeline_data 
  else 
    get_timeline_data(user_id)
  end
end
