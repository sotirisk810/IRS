# run_queries.py

from elasticsearch import Elasticsearch
import os

es = Elasticsearch("http://localhost:9200")
INDEX_NAME = "ir2025"

QUERIES_FILE = "queries.txt"   # Format: one query per line, with ID: e.g., 1 hiking in the forest
OUTPUT_FILE = "results/phase1.run"
TOP_K = 50

os.makedirs("results", exist_ok=True)

def parse_queries():
    queries = []
    with open(QUERIES_FILE, encoding="utf-8") as f:
        for line in f:
            parts = line.strip().split(maxsplit=1)
            if len(parts) == 2:
                query_id, query_text = parts
                queries.append((query_id, query_text))
    return queries

def run():
    queries = parse_queries()
    with open(OUTPUT_FILE, "w") as out:
        for query_id, query_text in queries:
            result = es.search(index=INDEX_NAME, size=TOP_K, body={
                "query": {"match": {"content": query_text}}
            })
            for rank, hit in enumerate(result["hits"]["hits"], start=1):
                doc_id = hit["_id"]
                score = hit["_score"]
                out.write(f"{query_id} Q0 {doc_id} {rank} {score:.4f} ElasticRun\n")

run()
print(f"Saved ranked results to {OUTPUT_FILE}")
