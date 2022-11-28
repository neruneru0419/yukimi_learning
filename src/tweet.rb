require "typhoeus"
require "json"
require "oauth"
require "byebug"

require_relative "yukimi_twitter"
require_relative "parser/parser"


module LambdaFunction
  class Handler
    def tweet(event:,context:)
      include YukimiTwitter
      include Parser
    
      yukimi_twitter = Twitter.new
      user_id = yukimi_twitter.get_user_id("runeru_runerune")["data"][0]["id"]
      timeline_data = yukimi_twitter.get_timeline(user_id)["data"].sample
      
      tweet_text = timeline_data["text"]
      tweet_id = timeline_data["id"]
      yukimi_text = change_yukimi(tweet_text)
    
      yukimi_twitter.post_tweet(yukimi_text)
      yukimi_twitter.post_favorite(user_id, tweet_id)
    end
  end
end
