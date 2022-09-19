=begin
require 'twitter'
require 'natto'
=end
class YukimiTwitter
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['MY_CONSUMER_KEY']
      config.consumer_secret = ENV['MY_CONSUMER_SECRET']
      config.access_token    = ENV['MY_ACCESS_TOKEN']
      config.access_token_secret = ENV['MY_ACCESS_TOKEN_SECRET']
    end
    @timeline_tweet_data = []
    @ngword = Ngword.new
    @client.home_timeline({ count: 100 }).each do |tweet|
      unless tweet.text.include?('RT') || tweet.text.include?('@') \
              || tweet.text.include?('http') || tweet.user.screen_name.include?('YukimiLearning') \
              || @ngword.ngword?(tweet.text) || (tweet.text.size > 100)
        @timeline_tweet_data.push({"tweet_text": tweet.text, "tweet_id": tweet.id})
      end
    end
  end

  def get_tweet_data
    @timeline_tweet_data
  end

  def get_tweet_texts
    #@timeline_tweet_dataのkeyがtweet_textな物を配列として返す
    @timeline_tweet_data.map {|ttd| ttd[:tweet_text]}
  end

  def get_tweet_ids
    #@timeline_tweet_dataのkeyがtweet_ idな物を配列として返す
    @timeline_tweet_data.map {|ttd| ttd[:tweet_id]}
  end

  def update_tweet
    tweet_data = []
    @client.home_timeline({ count: 100 }).each do |tweet|
      unless tweet.text.include?('RT') || tweet.text.include?('@') \
        || tweet.text.include?('http') || tweet.user.screen_name.include?('YukimiLearning') \
        || @ngword.ngword?(tweet.text) || (tweet.text) || (tweet.text.size > 100)
        tweet_data.push({"tweet_text": tweet.text, "tweet_id": tweet.id})
      end
    end
    @timeline_tweet_data = tweet_data
  end

  def get_reply
    yukimi_tweet = []
    @client.mentions_timeline.each do |tweet|
      yukimi_tweet.push(tweet)
    end
    yukimi_tweet
  end

  def tweet(str)
    @client.update(str)
  end

  def reply(str, option)
    @client.update(str,  options = option)
  end

  def get_follower_id
    @client.follower_ids.map{|follower| follower}
  end

  def get_followee_id
    @client.friend_ids.map{|followee| followee}
  end

  def get_users(user_id)
    @client.users(user_id)
  end

  def remove(user_id)
    @client.unfollow(user_id)
  end

  def favorite(user_id)
    @client.favorite(user_id)
  end
end
class Parser
  def initialize
    @nm = Natto::MeCab.new
  end

  def change_yukimi(markov_chain_text)
    p markov_chain_text
    nm = Natto::MeCab.new
    analyzed_tweets = []
    rand(1..4).times { analyzed_tweets.push('…') } if rand(4) == 0
    nm.parse(markov_chain_text) do |n|
      part_of_speech = ''
      analyzed_tweets.push(n.surface)
      n.feature.each_char do |block|
        part_of_speech += block
        break if block == '詞'
      end
      rand(1..4).times { analyzed_tweets.push('…') } if part_of_speech == '副詞' || part_of_speech == '助詞'
    end
    if rand(9) == 0
      rand(1..4).times { analyzed_tweets.push('…') }
      analyzed_tweets.push('ふふ')
      rand(1..4).times { analyzed_tweets.push('…') }
    end
    yukimi_tweet = analyzed_tweets.join
    new_str = ''
    yukimi_tweet.each_char do |s|
      if s == '#'
        new_str += "\n"
        new_str.delete!('…')
      end
      new_str += s
    end
    if 150 < new_str.size then
      change_yukimi(markov_chain_text)
    else
      new_str
    end
  end
end

class Ngword
  def initialize
    @ngwords = []
    File.foreach("ngword.txt") do |line|
      @ngwords.push(line.chomp)
      if line.chomp.match?(/\p{hiragana}/) then
        @ngwords.push(line.chomp.tr('ぁ-ん', 'ァ-ン'))
      elsif line.chomp.match?(/\p{katakana}/) then
        @ngwords.push(line.chomp.tr('ァ-ン', 'ぁ-ん'))
      end
    end
  end

  def ngword?(tweet_text)
    @ngwords.any?{|nw| tweet_text.include?(nw)}
  end
end

ng = Ngword.new

