require "typhoeus"
require "json"
require "oauth"
require "byebug"

require_relative "twitter/yukimi_twitter"
require_relative "parser/parser"
require_relative "ngword/ngword"

def reply
  include YukimiTwitter
  include Parser
  include Ngword
  
  user_id = get_user_id(UserName)["data"][0]["id"]
  reply_data = get_mention(user_id)["data"]

  reply_data.each do |reply|
    reply_id = reply["id"]
    author_id = reply["author_id"]

    unless reply_to_author?(author_id, reply_id)
      mention_data = get_user_timeline(author_id)["data"]
      mention_text = get_mention_text(mention_data)
      reply_text = change_yukimi(mention_text)
      post_reply(reply_text, reply_id)
    end
  end
end

def reply_to_author?(author_id, reply_id)
  yukimi_tweets = get_mention(author_id)["data"]

  yukimi_tweets.each do |mention|
    unless mention["referenced_tweets"].nil?
      referenced_tweets_id = mention["referenced_tweets"][0]["id"]
      return true if reply_id == referenced_tweets_id
    end
  end
  false
end

def get_mention_text(mention_data)
  mention_text = mention_data.sample["text"]
  if mention_text.include?("http") || mention_text.include?("#") || ngword?(mention_text)
    get_mention_text(mention_data)
  else
    mention_text    
  end
end

