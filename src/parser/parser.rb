require "natto"
module Parser
  def change_yukimi(text)
    nm = Natto::MeCab.new
    analyzed_tweets = []
    rand(1..4).times { analyzed_tweets.push('…') } if rand(4) == 0
    nm.parse(text) do |n|
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

    if 150 < yukimi_tweet.size then
      change_yukimi(text)
    else
      yukimi_tweet
    end
  end
end