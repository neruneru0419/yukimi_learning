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
    @timeline_tweet = []
    @client.home_timeline({ count: 100 }).each do |tweet|
      unless tweet.text.include?('RT') || tweet.text.include?('@') || tweet.text.include?('http') || tweet.user.screen_name.include?('YukimiLearning')
        @timeline_tweet.push(tweet.text)
      end
    end
  end

  def get_tweet
    return @timeline_tweet
  end

  def update_tweet
    tweets = []
    @client.home_timeline({ count: 100 }).each do |tweet|
      unless tweet.text.include?('RT') || tweet.text.include?('@') || tweet.text.include?('http') || tweet.user.screen_name.include?('YukimiLearning')
        tweets.push(tweet.text)
      end
      @timeline_tweet = tweets
    end
  end

  def get_reply
    yukimi_tweet = []
    @client.mentions_timeline.each do |tweet|
      yukimi_tweet.push(tweet)
    end
    return yukimi_tweet
  end

  def tweet(str)
    puts(str)
    # @client.update(str)
  end

  def reply(str, option)
    puts(str)
    # @client.update(str,  options = option)
  end
end

class NattoParser
  def initialize
    @nm = Natto::MeCab.new
  end

  def parse(timeline_tweet)
    @analyzed_tweets = ['']
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
      speech = speech.gsub(/[「」{}｛｝｢｣]/, '')
      tweet_block += parse(speech)
    end
    return tweet_block
  end

  def markov_chain(tweet_block)
    start_block = tweet_block.select { |block| block[0] == '' }
    markov_chain_text = start_block.sample
    chain_block = []
    ngflg = false
    while markov_chain_text[-1] != ''
      tweet_block.each do |tweet|
        chain_block.push(tweet) if markov_chain_text[-2] == tweet[0] && markov_chain_text[-1] == tweet[1]
      end
      break if chain_block.empty?

      chain_block.sample[2..-1].each do |block|
        markov_chain_text.push(block)
      end
      chain_block = []
    end

    tweet_sentence = markov_chain_text.join
    ngword = Ngword.new
    ngword_list = ngword.get_ngword
    ngword_list.each do |ng|
      ngflg = true if tweet_sentence.include?(ng)
    end
    puts tweet_sentence
    if (100 < tweet_sentence.size) || ngflg
      markov_chain(tweet_block)
    else
      return tweet_sentence
    end
  end

  def change_yukimi(markov_chain_text)
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

    return new_str
  end
end

class Ngword
  def initialize
    @ngwords = []
  end

  def get_ngword
    uri = URI.parse(ENV['DATABASE_URL'])
    connect = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
    results = connect.exec('select ngword from ngwords')

    results.each do |result|
      @ngwords.push(result['ngword'])
    end
    connect.finish

    return @ngwords
  end
end

$yukimi_twitter = YukimiTwitter.new

timeline_tweet = Thread.new do
  natto_parser = NattoParser.new
  loop do
    tweet = $yukimi_twitter.get_tweet
    tweet_block = natto_parser.parse_tweet(tweet)
    markov_chain_text = natto_parser.markov_chain(tweet_block)
    yukimi_tweet = natto_parser.change_yukimi(markov_chain_text)
    puts('tweet', yukimi_tweet)
    $yukimi_twitter.tweet(yukimi_tweet)
    sleep(900)
  end
end

reply_tweet = Thread.new do
  natto_parser = NattoParser.new
  yukimi_tweet_id = []
  $yukimi_twitter.get_reply.each do |tweet|
    yukimi_tweet_id.push(tweet.id)
  end
  loop do
    yukimi_reply = $yukimi_twitter.get_reply
    yukimi_reply.each do |tweet|
      next if yukimi_tweet_id.include?(tweet.id)

      tw = $yukimi_twitter.get_tweet
      tweet_block = natto_parser.parse_tweet(tw)
      markov_chain_text = natto_parser.markov_chain(tweet_block)
      yukimi_tweet = natto_parser.change_yukimi(markov_chain_text)
      $yukimi_twitter.reply("@#{tweet.user.screen_name} #{yukimi_tweet}", { in_reply_to_status_id: tweet.id })
      puts('replied')
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

if __FILE__ == $0
  timeline_tweet.join
  reply_tweet.join
  update.join
end
