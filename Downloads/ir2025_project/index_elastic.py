# index_elastic.py

from elasticsearch import Elasticsearch, helpers
import os
import re
import json

INDEX_NAME = "ir2025"
DOCS_DIR = "docs"  # folder with IR2025 .txt documents

def preprocess(text):
    text = text.lower()
    text = re.sub(r'\W+', ' ', text)
    return text.strip()

def load_documents():
    docs = []
    for filename in os.listdir(DOCS_DIR):
        if filename.endswith(".txt"):
            with open(os.path.join(DOCS_DIR, filename), encoding='utf-8') as f:
                content = preprocess(f.read())
                doc_id = filename.replace(".txt", "")
                docs.append({"_id": doc_id, "_source": {"content": content}})
    return docs

es = Elasticsearch("http://localhost:9200")

# Delete if exists
if es.indices.exists(index=INDEX_NAME):
    es.indices.delete(index=INDEX_NAME)

# Create index
es.indices.create(index=INDEX_NAME, body={
    "settings": {
        "analysis": {
            "analyzer": {
                "custom_english": {
                    "type": "standard",
                    "stopwords": "_english_"
                }
            }
        }
    },
    "mappings": {
        "properties": {
            "content": {"type": "text", "analyzer": "custom_english"}
        }
    }
})

# Index documents
documents = load_documents()
helpers.bulk(es, [{"_index": INDEX_NAME, **doc} for doc in documents])

print(f"Indexed {len(documents)} documents.")
