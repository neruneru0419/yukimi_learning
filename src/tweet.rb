require_relative "yukimi_twitter"
require_relative "parser/parser"


module LambdaFunction
  class Handler
    include YukimiTwitter
    include Parser

    def tweet(event:,context:)
      yukimi_twitter = YukimiTwitter.new
      tweet_data = yukimi_twitter
      parser
    end
  end
end

timeline_tweet = Thread.new do
  parser = Parser.new
  loop do
    tweet_data = $yukimi_twitter.get_tweet_data.sample
    p tweet_data
    tweet_text = tweet_data[:tweet_text]
    tweet_id = tweet_data[:tweet_id]
    yukimi_tweet = parser.change_yukimi(tweet_text)
    puts('tweet', yukimi_tweet)
    puts yukimi_tweet.size
    $yukimi_twitter.tweet(yukimi_tweet)
    $yukimi_twitter.favorite(tweet_id)
    sleep(900)
  end
end