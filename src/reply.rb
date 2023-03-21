require "typhoeus"
require "json"
require "oauth"
require "byebug"

require_relative "twitter/yukimi_twitter"
require_relative "parser/parser"
require_relative "ngword/ngword"

include YukimiTwitter
include Parser
include Ngword

module LambdaFunction
  class Handler
    def self.process(event:, context:)
      user_id = get_user_id(UserName)["data"][0]["id"]
      reply_data = get_mention(user_id)["data"]
      reply_data.each do |reply|
        reply_id = reply["id"]
        author_id = reply["author_id"]
        if reply_to_author?(author_id, reply_id, user_id)#もらったリプライのリプライを確認したい
          mention_text = get_mention_text(author_id, user_id)
          reply_text = change_yukimi(mention_text)
          post_reply(reply_text, reply_id)
        end
      end
    end
  end
end

def reply_to_author?(author_id, reply_id, user_id)
  #リプライをもらったユーザーが受けたメンション一覧を取得し、riamuからのメンションだけを厳選する
  #そのメンションが今回のリプライへの返信じゃないか確認する
  tw = []
  yukimi_tweets = get_mention(author_id)["data"]
  yukimi_tweets.each do |mention|
    unless mention["referenced_tweets"].nil?
      if mention["referenced_tweets"][0]["id"] == reply_id
        tw.push(mention)
      end
    end
  end
  tw.empty?
end

def get_mention_text(author_id, user_id)
  mention_data = get_user_timeline(author_id)["data"].sample
  mention_text = mention_data["text"]
  mention_id = mention_data["author_id"]
  unless mention_text.include?("http") || mention_text.include?("#") || ngword?(mention_text) || mention_id == user_id
    mention_text
  else
    get_mention_text(author_id, user_id)
  end
end
