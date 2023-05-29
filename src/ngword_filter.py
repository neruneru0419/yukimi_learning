import MeCab
import jaconv

def mk_mecab_list(word):
    tagger  = MeCab.Tagger("-Owakati")
    return(tagger.parse(word).split())

def judgement_sentence(sentence_word):
    text_list = []
    with open("../data/ngword.txt", encoding='utf-8') as data:
        for line in data:
            text = line.replace('\n','')
            text_list.append(text)
    paese_text = mk_mecab_list(sentence_word)
    for i in paese_text:
        if i in text_list:
            return True
        for j_text in text_list:
            if jaconv.hira2kata(j_text) == i:
                return True
