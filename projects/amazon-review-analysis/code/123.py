# For space reasons, we only show the key parts of the code in general here
from pathlib import Path

import pandas as pd
import spacy
import matplotlib
import numpy as np
import gensim
from gensim import corpora
import pyLDAvis.gensim
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import GridSearchCV
from imblearn.over_sampling import RandomOverSampler

DATA_DIR = Path(__file__).resolve().parents[1] / "data"
# Data processing section
df = pd.read_csv(DATA_DIR / "app3.csv")
df.head()
df = df.dropna(subset=['reviewText'])
df['reviewText'] = df['reviewText'].str.replace("[^a-zA-Z#]", " ")
from nltk.corpus import stopwords
stop_words = stopwords.words('english')
def remove_stopwords(rev):
    rev_new = " ".join([i for i in rev if i not in stop_words])
    return rev_new
df['reviewText'] = df['reviewText'].apply(lambda x: ' '.join([w for w in x.split() if len(w)>2]))
reviews = [remove_stopwords(r.split()) for r in df['reviewText']]
reviews = [r.lower() for r in reviews]
nlp = spacy.load('en_core_web_sm', disable=['parser', 'ner'])
def lemmatization(texts, tags=['NOUN']):
       output = []
       for sent in texts:
             doc = nlp(" ".join(sent))
             output.append([token.lemma_ for token in doc if token.pos_ in tags])
       return output
tokenized_reviews = pd.Series(reviews).apply(lambda x: x.split())
reviews_2 = lemmatization(tokenized_reviews)
reviews_3 = []
for i in range(len(reviews_2)):
 reviews_3.append(' '.join(reviews_2[i]))
df['reviews'] = reviews_3
print(df['reviews'])
#LDA section
dictionary = corpora.Dictionary(reviews_2)
doc_term_matrix = [dictionary.doc2bow(rev) for rev in reviews_2]
# Creating the object for LDA model using gensim library
LDA = gensim.models.ldamodel.LdaModel
# Build LDA model
lda_model = LDA(corpus=doc_term_matrix,
id2word=dictionary,
        num_topics=10,
        random_state=100,
        chunksize=1000,
        passes=50)
topics=lda_model.print_topics()
#K-means section
# Create a TfidfVectorizer object
vectorizer = TfidfVectorizer()
# Compute the tf-idf vectors for the text data
tfidf_matrix = vectorizer.fit_transform(df['reviews'])
# Create a KMeans object with the desired number of clusters
kmeans = KMeans(n_clusters=100,n_init=10)
# Fit the KMeans model to the tf-idf vectors
kmeans.fit(tfidf_matrix)
# Naive Bayes part
# Suppose you already have a dataset that contains the review text and ratings
data = pd.read_csv(DATA_DIR / "app4.csv")
data = data.dropna(subset=['reviewText'])
data = data.dropna(subset=['summary'])
# Extract evaluation text and score
comments = data['reviewText'].tolist()
ratings = data['overall'].tolist()
summary = data['summary'].tolist()
# Converts text data to feature vectors
vectorizer1 = CountVectorizer()
vectorizer2 = CountVectorizer()
X1 = vectorizer1.fit_transform(comments)
X2 = vectorizer2.fit_transform(summary)
# Oversampling
ros = RandomOverSampler(random_state=0)
X1_resampled, y1_resampled = ros.fit_resample(X1, ratings)
X2_resampled, y2_resampled = ros.fit_resample(X2, ratings)
# Train naive Bayes models
clf1 = MultinomialNB()
clf1.fit(X1_resampled, y1_resampled)
clf2 = MultinomialNB()
clf2.fit(X2_resampled, y2_resampled)
# Read data that needs to be predicted
test_data = pd.read_csv(DATA_DIR / "app6.csv")
test_data = test_data.dropna(subset=['reviewText'])
test_data = test_data.dropna(subset=['summary'])
test_comments = test_data['reviewText'].tolist()
test_summary = test_data['summary'].tolist()
# Convert test data to feature vectors
X_test_c = vectorizer1.transform(test_comments)
X_test_s = vectorizer2.transform(test_summary)
# Predict the score of test data
predicted_ratings1 = clf1.predict(X_test_c)
predicted_ratings2 = clf2.predict(X_test_s)
