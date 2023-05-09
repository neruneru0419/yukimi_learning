import re
from collections import deque
import random
from misskey import Misskey
import json
import requests

with open('../../config.json', 'r') as json_file:
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



def mk_misskey_list():
    text_list = []
    with open("../../data/get_timeline_list.txt", encoding='utf-8') as data:
        for line in data:
            text = line.rstrip('\n')
            text_list.append(text)
    return text_list

def get_tl_misskey():
    text_list = []
    response = requests.post(
        get_tl_url,
        json.dumps(get_tl_json_data),
        headers={'Content-Type': 'application/json'})
    hash = response.json()
    for num in range(limit):
        line = str(hash[num]["text"])
        line = re.sub(r'https?://[\w/:%#\$&\?\(\)~\.=\+\-…]+', "", line)
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
        deq_list = line in text_list
        if line != "None" and line != "" and deq_list == False:
            with open('../../data/get_timeline_list.txt', 'a',encoding='utf-8') as f:
                print(line, file=f)
            text_list.append(line)
    return text_list


print(get_tl_misskey())