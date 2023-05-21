import re
from collections import deque
import random
from misskey import Misskey
import json
import requests

with open('../config.json', 'r') as json_file:
    config = json.load(json_file)

#Misskey.py API
misskey = Misskey(config['token']['server'], i= config['token']['i'])

#Misskey API json request用
get_tl_url = "https://" + config['token']['server'] + "/api/notes/timeline"
limit = 30
get_tl_json_data = {
    "i" : config["token"]["i"],
    "limit": limit,
}



# ToDo:この部分をmfm-jsでデコードするようにする
def get_tl_misskey():
    text_list = []
    response = requests.post(
        get_tl_url,
        json.dumps(get_tl_json_data),
        headers={'Content-Type': 'application/json'})
    hash = response.json()
    choice_note = random.choice(hash)
    choice_id = str(choice_note["id"]) 
    choice_text = str(choice_note["text"])
    misskey.notes_reactions_create(choice_id,"❤️")
    return(choice_text)

# print(get_tl_misskey())