from pathlib import Path

import pandas as pd
from nltk.corpus import stopwords
from collections import Counter
import spacy

DATA_DIR = Path(__file__).resolve().parents[1] / "data"
df = pd.read_csv(DATA_DIR / "app4.csv", usecols=['asin', 'reviewText', 'summary'])
df['reviewText'] = df['reviewText'].astype(str)
df['summary'] = df['summary'].astype(str)

df['text'] = df.groupby('asin')['reviewText'].transform(lambda x: ' '.join(x)) + ' ' + df.groupby('asin')['summary'].transform(lambda x: ' '.join(x))
df = df[['asin', 'text']].drop_duplicates()

df['text'] = df['text'].str.replace("[^a-zA-Z#]", " ")

stop_words = stopwords.words('english')
df['text'] = df['text'].apply(lambda x: ' '.join([w for w in x.split() if w not in stop_words]))

nlp = spacy.load('en_core_web_sm', disable=['parser', 'ner'])
def lemmatization(texts, tags=['NOUN']):
    output = []
    for sent in texts:
        doc = nlp(sent)
        output.append(' '.join([token.lemma_ for token in doc if token.pos_ in tags]))
    return output

df['text'] = lemmatization(df['text'])

def top_words(text, n=10):
    words = text.split()
    word_counts = Counter(words)
    return [word for word, count in word_counts.most_common(n)]

df['top_words'] = df['text'].apply(top_words)

for index, row in df.iterrows():
    print(row['asin'], row['top_words'])
