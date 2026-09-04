from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from pathlib import Path

import pandas as pd
pd.set_option("display.max_colwidth", 200)
import spacy
# libraries for visualization
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('TkAgg')
DATA_DIR = Path(__file__).resolve().parents[1] / "data"
df = pd.read_csv(DATA_DIR / "app4.csv")
df.head()
#delete space
df = df.dropna(subset=['reviewText'])
# remove unwanted characters, numbers and symbols
df['reviewText'] = df['reviewText'].str.replace("[^a-zA-Z#]", " ")
from nltk.corpus import stopwords
stop_words = stopwords.words('english')
# function to remove stopwords
def remove_stopwords(rev):
    rev_new = " ".join([i for i in rev if i not in stop_words])
    return rev_new
# remove short words (length < 3)
df['reviewText'] = df['reviewText'].apply(lambda x: ' '.join([w for w in x.split() if len(w)>2]))
# remove stopwords from the text
reviews = [remove_stopwords(r.split()) for r in df['reviewText']]
# make entire text lowercase
reviews = [r.lower() for r in reviews]
nlp = spacy.load('en_core_web_sm', disable=['parser', 'ner'])
def lemmatization(texts, tags=['NOUN']): # filter noun
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
# Create a TfidfVectorizer object
vectorizer = TfidfVectorizer()

# Compute the tf-idf vectors for the text data
tfidf_matrix = vectorizer.fit_transform(df['reviews'])

# Create a KMeans object with the desired number of clusters
kmeans = KMeans(n_clusters=100,n_init=10)

# Fit the KMeans model to the tf-idf vectors
kmeans.fit(tfidf_matrix)

# # Visualize the clustering results using a scatter plot
# plt.scatter(tfidf_matrix[:, 0], tfidf_matrix[:, 1], c=kmeans.labels_)
# plt.show()
# Create a PCA object
pca = PCA(n_components=2)

# Fit the PCA model to the tf-idf vectors
pca.fit(tfidf_matrix.toarray())

# Transform the tf-idf vectors to 2D
tfidf_2d = pca.transform(tfidf_matrix.toarray())

# Visualize the clustering results using a scatter plot
plt.scatter(tfidf_2d[:, 0], tfidf_2d[:, 1], c=kmeans.labels_)
plt.show()
