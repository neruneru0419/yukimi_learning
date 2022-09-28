require 'twitter'
require 'natto'

class YukimiTwitter
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV.fetch('MY_CONSUMER_KEY')
      config.consumer_secret = ENV.fetch('MY_CONSUMER_SECRET')
      config.access_token    = ENV.fetch('MY_ACCESS_TOKEN')
      config.access_token_secret = ENV.fetch('MY_ACCESS_TOKEN_SECRET')
    end
    @timeline_tweet_data = []
    @ngword = Ngword.new
    @client.home_timeline({ count: 100 }).each do |tweet|
      next if ['RT', '@', 'http'].any? { |remove_str| tweet.text.include?(remove_str) } \
        || tweet.user.screen_name.include?('YukimiLearning') || @ngword.ngword?(tweet.text) \
        || (tweet.text.size > 100)

      @timeline_tweet_data.push({ tweet_text: tweet.text, tweet_id: tweet.id })
    end
  end

  def self.tweet_data
    @timeline_tweet_data
  end

  def self.tweet_texts
    # @timeline_tweet_dataのkeyがtweet_textな物を配列として返す
    @timeline_tweet_data.map { |ttd| ttd[:tweet_text] }
  end

  def self.tweet_ids
    # @timeline_tweet_dataのkeyがtweet_ idな物を配列として返す
    @timeline_tweet_data.map { |ttd| ttd[:tweet_id] }
  end

  def self.update_tweet
    tweet_data = []
    @client.home_timeline({ count: 100 }).each do |tweet|
      next if ['RT', '@', 'http'].any? { |remove_str| tweet.text.include?(remove_str) } \
        || tweet.user.screen_name.include?('YukimiLearning') || @ngword.ngword?(tweet.text) \
        || (tweet.text.size > 100)

      @timeline_tweet_data.push({ tweet_text: tweet.text, tweet_id: tweet.id })
    end
    @timeline_tweet_data = tweet_data
  end

  def self.reply
    yukimi_tweet = []
    @client.mentions_timeline.each do |tweet|
      yukimi_tweet.push(tweet)
    end
    yukimi_tweet
  end

  def self.tweet(message, options = nil)
    @client.update(message, options)
  end

  def self.follower_id
    @client.follower_ids.map { |follower| follower }
  end

  def self.followee_id
    @client.friend_ids.map { |followee| followee }
  end

  def self.users(user_id)
    @client.users(user_id)
  end

  def self.remove(user_id)
    @client.unfollow(user_id)
  end

  def self.favorite(user_id)
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
    rand(1..4).times { analyzed_tweets.push('…') } if rand(4).zero?
    nm.parse(markov_chain_text) do |n|
      part_of_speech = ''
      analyzed_tweets.push(n.surface)
      n.feature.each_char do |block|
        part_of_speech += block
        break if block == '詞'
      end
      rand(1..4).times { analyzed_tweets.push('…') } if %w(副詞 助詞).include?(part_of_speech)
    end
    if rand(9).zero?
      rand(1..4).times { analyzed_tweets.push('…') }
      analyzed_tweets.push('ふふ')
      rand(1..4).times { analyzed_tweets.push('…') }
    end
    yukimi_tweet = ''
    analyzed_tweets.join.each_char do |s|
      if s == '#'
        yukimi_tweet += '\n'
        yukimi_tweet.delete!('…')
      end
      yukimi_tweet += s
    end
    yukimi_tweet.size > 150 ? change_yukimi(markov_chain_text) : yukimi_tweet
  end
end

class Ngword
  def initialize
    @ngwords = []
    File.foreach('ngword.txt') do |line|
      @ngwords.push(line.chomp)
      if line.chomp.match?(/\p{hiragana}/)
        @ngwords.push(line.chomp.tr('ぁ-ん', 'ァ-ン'))
      elsif line.chomp.match?(/\p{katakana}/)
        @ngwords.push(line.chomp.tr('ァ-ン', 'ぁ-ん'))
      end
    end
  end

  def ngword?(tweet_text)
    @ngwords.any? { |nw| tweet_text.include?(nw) }
  end
end

timeline_tweet = Thread.new do
  parser = Parser.new
  loop do
    tweet_data = YukimiTwitter.tweet_data.sample
    p tweet_data
    tweet_text = tweet_data[:tweet_text]
    tweet_id = tweet_data[:tweet_id]
    yukimi_tweet = parser.change_yukimi(tweet_text)
    puts('tweet', yukimi_tweet)
    puts yukimi_tweet.size
    YukimiTwitter.tweet(yukimi_tweet)
    YukimiTwitter.favorite(tweet_id)
    sleep(900)
  end
end

reply_tweet = Thread.new do
  parser = Parser.new
  yukimi_tweet_id = []
  YukimiTwitter.reply.each do |tweet|
    yukimi_tweet_id.push(tweet.id)
  end
  loop do
    yukimi_reply = YukimiTwitter.reply
    yukimi_reply.each do |tweet|
      next if yukimi_tweet_id.include?(tweet.id)

      tweet_text = YukimiTwitter.tweet_texts.sample
      yukimi_tweet = parser.change_yukimi(tweet_text)
      YukimiTwitter.tweet("@#{tweet.user.screen_name} #{yukimi_tweet}", { in_reply_to_status_id: tweet.id })
      puts('replied')
      YukimiTwitter.favorite(tweet.id)
      yukimi_tweet_id.push(tweet.id)
    end
    sleep(60)
  end
end

update = Thread.new do
  loop do
    sleep(900)
    YukimiTwitter.update_tweet
  end
end

remove = Thread.new do
  loop do
    follower_ids = YukimiTwitter.follower_id
    followee_ids = YukimiTwitter.followee_id

    users_ids = followee_ids - follower_ids
    users_ids.each do |user_id|
      YukimiTwitter.remove(user_id)
    end
    sleep(900)
  end
end

timeline_tweet.join
reply_tweet.join
update.join
remove.join
