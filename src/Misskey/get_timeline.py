# 1つ上のディレクトリの絶対パスを取得し、sys.pathに登録する
import sys
from os.path import dirname
parent_dir = dirname(dirname(__file__))
if parent_dir not in sys.path:
    sys.path.append(parent_dir) 

import re
from collections import deque
from ngword_filter import judgement_sentence
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
limit = 15
get_tl_json_data = {
    "i" : config["token"]["i"],
    "limit": limit,
}



# ToDo:この部分をmfm-jsでデコードするようにする
def get_tl_misskey():
    response = requests.post(
        get_tl_url,
        json.dumps(get_tl_json_data),
        headers={'Content-Type': 'application/json'})
    hash = response.json()
    choice_note = random.choice(hash)
    choice_id = str(choice_note["id"]) 
    choice_text = str(choice_note["text"])
    line = re.sub(r'https?://[\w/:%#\$&\?\(\)~\.=\+\-…]+', "", choice_text)
    line = re.sub(r'@.*', "", line)
    line = re.sub(r'#.*', "", line)
    line = re.sub(r':.*', "", line)
    line = re.sub(r"<[^>]*?>", "", line)
    line = re.sub(r"\(.*", "", line)
    line = line.replace('\\', "")
    line = line.replace('*', "")
    line = line.replace('\n', "")
    line = line.replace('\u3000', "")
    line = line.replace('俺', "私")
    line = line.replace('僕', "私")
    line = line.replace(' ', "")
    mfm_judge = list(line)
    for one_letter in mfm_judge:
        if(one_letter == '$'):
            return "None"
    if judgement_sentence(line) != True and line != "None" and line != "":
        misskey.notes_reactions_create(choice_id,"❤️")
        return(line)
    else:
        return "None"
    
# print(get_tl_misskey())