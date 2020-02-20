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
  end

  def get_tweet
	  @timeline_tweet = []
	  @timeline_tweet_id = []
	  @client.home_timeline({count: 100}).each do |tweet|
	    unless tweet.text.include?("RT") or tweet.text.include?("@") or tweet.text.include?("http") or tweet.user.screen_name.include?("YukimiLearning") then
        @timeline_tweet.push(tweet.text)
		    @timeline_tweet_id.push(tweet.id)
	    end
	  end
	  puts(@timeline_tweet)
	  return @timeline_tweet
  end

  def tweet(str)
	  @client.update(str)
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
	  (@analyzed_tweets.size - 2).times do |split_tweet|
			tweet_block = @analyzed_tweets[split_tweet..(split_tweet + 2)]
			@tweet_blocks.push(tweet_block)
	  end
	  return @tweet_blocks
  end
  
	def get_yukimi_speech(tweet)
	  tweet_block = []
	  tweet.each do |speech|
	    tweet_block += parse(speech)
	  end
	  return tweet_block
  end
  
	def markov_chain(yukimi_blocks)
	  start_block = yukimi_blocks.select{|block| block[0] == ""}
	  markov_chain_text = start_block.sample
	  chain_block = []
	  while (markov_chain_text[-1] != "") do 
			yukimi_blocks.each do |tweet|
		    #語尾と語頭が同じブロックの候補を配列に格納
		    chain_block.push(tweet[1..-1]) if markov_chain_text[-1] == tweet[0]
			end
			#候補がない場合強制的にループを終了
			break if chain_block.empty?
			#ブロックの連結
			markov_chain_text += chain_block.sample
			#p markov_chain_text
			#配列の初期化
			chain_block = []
	  end
	  #ブロックを連結した文字列を返す
	  if 100 < markov_chain_text.join.size then
		  return markov_chain(yukimi_blocks)
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
		if rand(9) == 0
		  rand(1..4).times {analyzed_tweets.push("…")} 
		  analyzed_tweets.push("ふふ")
			rand(1..4).times {analyzed_tweets.push("…")} 
		end
		return analyzed_tweets.join
	end
end

def timeline_tweet 
  natto_parser = NattoParser.new
  yukimi_twitter = YukimiTwitter.new
  loop do
	  tweet = yukimi_twitter.get_tweet
    tweet_block = natto_parser.get_yukimi_speech(tweet)
	  markov_chain_text = natto_parser.markov_chain(tweet_block)
	  yukimi_twitter.tweet(natto_parser.change_yukimi(markov_chain_text))
    sleep(900)
  end
end

if __FILE__ == $0
  timeline_tweet
end

