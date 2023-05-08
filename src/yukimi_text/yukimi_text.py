import MeCab
import random

def change_yukimi(text):
    tagger = MeCab.Tagger()
    analyzed_tweets = []

    if random.randint(0, 3) == 0:
        for _ in range(random.randint(1, 4)):
            analyzed_tweets.append("…")

    node = tagger.parseToNode(text)
    while node:
        part_of_speech = ''
        analyzed_tweets.append(node.surface)
        for block in node.feature:
            part_of_speech += block
            if block == '詞':
                break
        if part_of_speech == '副詞' or part_of_speech == '助詞':
            for _ in range(random.randint(1, 4)):
                analyzed_tweets.append("…")

        node = node.next

    if random.randint(0, 7) == 0:
        for _ in range(random.randint(1, 4)):
            analyzed_tweets.append("…")
        analyzed_tweets.append("ふふ")
        for _ in range(random.randint(1, 4)):
            analyzed_tweets.append("…")

    yukimi_tweet = "".join(analyzed_tweets)

    if len(yukimi_tweet) > 150:
        return change_yukimi(text)
    else:
        return yukimi_tweet
change_yukimi("これはテストです")