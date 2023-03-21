require "typhoeus"
require "json"
require "oauth"
require "byebug"

require_relative "twitter/yukimi_twitter"
require_relative "parser/parser"

include YukimiTwitter

module LambdaFunction
  class Handler
    def self.process(event:, context:)
      user_id = get_user_id(UserName)["data"][0]["id"]
      follower_ids = get_follower_id(user_id)["data"].map{ |follower_id| follower_id["id"]}
      followee_ids = get_followee_id(user_id)["data"].map{ |followee_id| followee_id["id"]}

      remove_user_ids = followee_ids - follower_ids
      for remove_user_id in remove_user_ids do
        delete_remove(user_id, remove_user_id)
      end
    end
  end
end
