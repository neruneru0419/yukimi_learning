require "typhoeus"
require "json"
require "oauth"
require "byebug"

require_relative "yukimi_twitter"
require_relative "parser/parser"

=begin
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
=end

def reply
  include YukimiTwitter
  include Parser

  yukimi_twitter = Twitter.new
  user_id = yukimi_twitter.get_user_id("runeru_runerune")["data"][0]["id"]
  reply_id = yukimi_twitter.get_mention(user_id)["data"].first["id"]
  mention_text = "うんち" # ここuser_timelineから取得する
  # yukimi_reply = parser.change_yukimi(mention_text)
  # 既にリプライが送られていた場合はリプライしない
  yukimi_twitter.post_reply(mention_text, reply_id)
end
p reply
=begin
parser = Parser.new
yukimi_tweet_id = []
$yukimi_twitter.get_reply.each do |tweet|
  yukimi_tweet_id.push(tweet.id)
end
loop do
  yukimi_reply = $yukimi_twitter.get_reply
  yukimi_reply.each do |tweet|
    next if yukimi_tweet_id.include?(tweet.id)

    tweet_text = $yukimi_twitter.get_tweet_texts.sample
    yukimi_tweet = parser.change_yukimi(tweet_text)
    $yukimi_twitter.reply("@#{tweet.user.screen_name} #{yukimi_tweet}", { in_reply_to_status_id: tweet.id })
    puts('replied')
    $yukimi_twitter.favorite(tweet.id)
    yukimi_tweet_id.push(tweet.id)
  end
  sleep(60)
end
=end