### main.py
from apscheduler.schedulers.blocking import BlockingScheduler
from Misskey.note import note
from Misskey.get_timeline import get_tl_misskey
from Misskey.follow_back import follow_back
from yukimi_text.yukimi_text import change_yukimi
import logging
import random
import asyncio

logging.basicConfig(level=logging.DEBUG)
asyncio.get_event_loop().run_until_complete(follow_back())


sched = BlockingScheduler()
class Config(object):
    SCHEDULER_API_ENABLED = True

@sched.scheduled_job('cron', id='note', minute='*/10')
def cron_note():
    text = get_tl_misskey()
    word = random.choice(text)
    post_word = change_yukimi(word)
    note(post_word)
    
    
if __name__ == "__main__":
    sched.start()
