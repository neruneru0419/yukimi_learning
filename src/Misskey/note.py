from ngword_filter import judgement_sentence
import numpy as np
from misskey import Misskey
import json


with open('../config.json', 'r') as json_file:
    config = json.load(json_file)
misskey = Misskey(config['token']['server'], i= config['token']['i'])


def note(sentence):
    if judgement_sentence(sentence) != True:
        misskey.notes_create(sentence)