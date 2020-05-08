require "twitter"
require 'natto'

class YukimiTwitter
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['MY_CONSUMER_KEY']
      config.consumer_secret = ENV['MY_CONSUMER_SECRET']
      config.access_token    = ENV['MY_ACCESS_TOKEN']
      config.access_token_secret = ENV['MY_ACCESS_TOKEN_SECRET']
    end
    @yukimi_tweet_id = @client.mentions_timeline.map{|tweet| tweet.id}
    @timeline_tweet = []
    @client.home_timeline({count: 100}).each do |tweet|
      unless tweet.text.include?("RT") or tweet.text.include?("@") or tweet.text.include?("http") or tweet.user.screen_name.include?("YukimiLearning") then
        @timeline_tweet.push(tweet.text)
      end
    end
  end

  def get_tweet
    return @timeline_tweet
  end

  def get_tweet_id
    return @yukimi_tweet_id
  end

  def update_tweet
    tweets = []
    @client.home_timeline({count: 100}).each do |tweet|
      unless tweet.text.include?("RT") or tweet.text.include?("@") or tweet.text.include?("http") or tweet.user.screen_name.include?("YukimiLearning") then
        tweets.push(tweet.text)
      end
      @timeline_tweet = tweets
    end

  end
  def get_reply
    yukimi_tweet = []
    @client.mentions_timeline.each do |tweet|
      puts "\e[33m" + tweet.user.name + "\e[32m" + "[ID:" + tweet.user.screen_name + "]"
      puts "\e[0m" + tweet.text
      yukimi_tweet.push(tweet)
      @yukimi_tweet_id.push(tweet.id)
    end
    return yukimi_tweet
  end
  def tweet(str)
    @client.update(str)
  end

  def reply(str, option)
    @client.update(str,  options = option)
  end
end
    
    
    
class NattoParser
  def initialize()
    @nm = Natto::MeCab.new
  end

  def parse(timeline_tweet)
    @analyzed_tweets = [""]
    @tweet_blocks = []
    @nm.parse(timeline_tweet) do |n|
      @analyzed_tweets.push(n.surface)
    end
    (@analyzed_tweets.size - 3).times do |split_tweet|
      tweet_block = @analyzed_tweets[split_tweet..(split_tweet + 3)]
      @tweet_blocks.push(tweet_block)
    end
    return @tweet_blocks
  end

  def parse_tweet(tweet)
    tweet_block = []
    tweet.each do |speech|
      speech = speech.gsub(/[「」{}｛｝｢｣]/,"")
      tweet_block += parse(speech)
    end
    return tweet_block
  end

  def markov_chain(tweet_block)
    start_block = tweet_block.select{|block| block[0] == ""}
    markov_chain_text = start_block.sample
    chain_block = []
    while (markov_chain_text[-1] != "") do
      tweet_block.each do |tweet|
        chain_block.push(tweet) if markov_chain_text[-2] == tweet[0] && markov_chain_text[-1] == tweet[1]
      end
      break if chain_block.empty?
      chain_block.sample[2..-1].each do |block|
        markov_chain_text.push(block)
      end
      chain_block = []
    end
    if 100 < markov_chain_text.join.size then
      return markov_chain(tweet_block)
    else
      return markov_chain_text.join
    end
  end

  def change_yukimi(markov_chain_text)
    nm = Natto::MeCab.new
    analyzed_tweets = []
    rand(1..4).times {analyzed_tweets.push("…")} if rand(4) == 0 
    nm.parse(markov_chain_text) do |n|
      part_of_speech = ""
      analyzed_tweets.push(n.surface)
      (n.feature).each_char do |block|
        part_of_speech += block
        break if block == "詞" 
      end
      rand(1..4).times {analyzed_tweets.push("…")} if part_of_speech == "副詞" || part_of_speech == "助詞"
    end
    if rand(9) == 0 then
      rand(1..4).times {analyzed_tweets.push("…")} 
      analyzed_tweets.push("ふふ")
      rand(1..4).times {analyzed_tweets.push("…")} 
    end
    return analyzed_tweets.join
  end
end

$yukimi_twitter = YukimiTwitter.new

timeline_tweet = Thread.new do 
  natto_parser = NattoParser.new
  sleep(120)
  loop do
    tweet = $yukimi_twitter.get_tweet
    tweet_block = natto_parser.parse_tweet(tweet)
    markov_chain_text = natto_parser.markov_chain(tweet_block)
    yukimi_tweet = natto_parser.change_yukimi(markov_chain_text)
    $yukimi_twitter.tweet(yukimi_tweet)
    sleep(900)
  end
end


reply_tweet = Thread.new do
  natto_parser = NattoParser.new
  yukimi_tweet_id = $yukimi_twitter.get_tweet_id
  loop do
    yukimi_reply = $yukimi_twitter.get_reply
    yukimi_reply.each do |tweet|
      unless yukimi_tweet_id.include?(tweet.id) then
        tw = $yukimi_twitter.get_tweet
        tweet_block = natto_parser.parse_tweet(tw)
        markov_chain_text = natto_parser.markov_chain(tweet_block)
        $yukimi_twitter.reply(markov_chain_text, {:in_reply_to_status_id => tweet.id})
        yukimi_tweet_id.push(tweet.id)
      end
    end
    sleep(60)
  end
end

update = Thread.new do
  loop do
    sleep(900)
    $yukimi_twitter.update_tweet
  end
end

if __FILE__ == $0
  timeline_tweet.join
  reply_tweet.join
  update.join
end

