
import re
from collections import deque
from misskey import Misskey
import json
import websockets

with open('../config.json', 'r') as json_file:
    config = json.load(json_file)

#Misskey.py API
misskey = Misskey(config['token']['server'], i= config['token']['i'])

MY_ID = misskey.i()['id']
WS_URL='wss://'+ config['token']['server'] +'/streaming?i='+ config['token']['i']

async def follow_back():
 async with websockets.connect(WS_URL) as ws:
    await ws.send(json.dumps({
   "type": "connect",
   "body": {
     "channel": "main",
     "id": "test"
   }
  }))
    
    while True:
      data = json.loads(await ws.recv())
      if data['type'] == 'channel':
        if data['body']['type'] == 'followed':
          user = data['body']['body']
        await on_follow(user)

async def on_follow(user):
  try:
    misskey.following_create(user['id'])
  except:
    pass
  
