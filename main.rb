require 'twitter'
require 'natto'
require 'pg'


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
    return @timeline_tweet_data
  end

  def get_tweet_texts
    #@timeline_tweet_dataのkeyがtweet_textな物を配列として返す
    return @timeline_tweet_data.map {|ttd| ttd[:tweet_text]}
  end

  def get_tweet_ids
    #@timeline_tweet_dataのkeyがtweet_ idな物を配列として返す
    return @timeline_tweet_data.map {|ttd| ttd[:tweet_id]}
  end

  def update_tweet
    tweet_data = []
    @client.home_timeline({ count: 100 }).each do |tweet|
      unless tweet.text.include?('RT') || tweet.text.include?('@') \
        || tweet.text.include?('http') || tweet.user.screen_name.include?('YukimiLearning') \
        || @ngword.ngword?(tweet.text) || (tweet.text.size > 100)
      end
    end
    @timeline_tweet_data = tweet_data
  end

  def get_reply
    yukimi_tweet = []
    @client.mentions_timeline.each do |tweet|
      yukimi_tweet.push(tweet)
    end
    return yukimi_tweet
  end

  def tweet(str)
    @client.update(str)
  end

  def reply(str, option)
    @client.update(str,  options = option)
  end


  def get_follower_id
    return @client.follower_ids.map{|follower| follower}
  end

  def get_followee_id
    return @client.friend_ids.map{|followee| followee}
  end

  def get_users(user_id)
    return @client.users(user_id)
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
      return new_str
    end
  end
end

class Ngword
  def initialize
    @ngwords = []
    uri = URI.parse(ENV['DATABASE_URL'])
    connect = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
    results = connect.exec('select ngword from ngwords')

    results.each do |result|
      @ngwords.push(result['ngword'])
      if result['ngword'].match?(/\p{hiragana}/) then
        @ngwords.push(result['ngword'].tr('ぁ-ん', 'ァ-ン'))
      elsif result['ngword'].match?(/\p{katakana}/) then
        @ngwords.push(result['ngword'].tr('ァ-ン', 'ぁ-ん'))
      end
    end
    connect.finish
  end

  def ngword?(tweet_text)

    return @ngwords.include?(tweet_text)
  end
end
$yukimi_twitter = YukimiTwitter.new

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

reply_tweet = Thread.new do
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
end

update = Thread.new do
  loop do
    sleep(900)
    $yukimi_twitter.update_tweet
  end
end

remove = Thread.new do
  loop do
    follower_ids = $yukimi_twitter.get_follower_id
    followee_ids = $yukimi_twitter.get_followee_id

    users_ids = followee_ids - follower_ids
    for user_id in users_ids do 
      $yukimi_twitter.remove(user_id)
    end
    sleep(900)
  end
end

if __FILE__ == $0
  timeline_tweet.join
  reply_tweet.join
  update.join
  remove.join
end