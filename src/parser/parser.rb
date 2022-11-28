module Parser
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
    if 150 < new_str.size then
      change_yukimi(markov_chain_text)
    else
      new_str
    end
  end
end