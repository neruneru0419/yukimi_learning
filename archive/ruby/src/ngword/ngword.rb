module Ngword
  def ngword?(tweet_text)
    ngwords = []
    File.foreach("src/ngword/ngword.txt") do |line|
      ngwords.push(line.chomp)
      if line.chomp.match?(/\p{hiragana}/) then
        ngwords.push(line.chomp.tr('ぁ-ん', 'ァ-ン'))
      elsif line.chomp.match?(/\p{katakana}/) then
        ngwords.push(line.chomp.tr('ァ-ン', 'ぁ-ん'))
      end
    end
    ngwords.any?{|nw| tweet_text.include?(nw)}
  end
end