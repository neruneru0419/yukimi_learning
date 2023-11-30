from misskey import Misskey
import json
import requests

with open('../config_yukimi.json', 'r') as json_file:
    config = json.load(json_file)

#Misskey.py API
misskey = Misskey(config['token']['server'], i=config['token']['i'])

followers_data_url = "https://" + config['token']['server'] + "/api/users/followers"
follow_url = "https://" + config['token']['server'] + "/api/following/create"

def get_followers():
    followers_len = misskey.i()["followersCount"]
    followers = get_limit_followers()
    until_id = followers[-1]["id"]
    while len(followers) <= followers_len:
        followers += get_limit_followers(until_id=until_id)
        until_id = followers[-1]["id"]
    return followers

def get_limit_followers(until_id=None):
    limit = 100
    if until_id:
        get_tl_json_data = {
            "i" : config["token"]["i"],
            "limit": limit,
            "untilId": until_id,
            "userId": misskey.i()["id"]
        }
    else:
        get_tl_json_data = {
            "i" : config["token"]["i"],
            "limit": limit,
            "userId": misskey.i()["id"]
        }
    
    response = requests.post(
        followers_data_url,
        json.dumps(get_tl_json_data),
        headers={'Content-Type': 'application/json'})
    return response.json()

