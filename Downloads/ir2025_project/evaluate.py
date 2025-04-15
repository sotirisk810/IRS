import pytrec_eval
import os

QRELS_FILE = "qrels.txt"
RUN_FILE = "results/phase1.run"

# Load qrels (relevance judgments)
qrels = {}
with open(QRELS_FILE, "r", encoding="utf-8") as f:
    for line in f:
        query_id, _, doc_id, relevance = line.strip().split()
        qrels.setdefault(query_id, {})[doc_id] = int(relevance)

# Load run (retrieved results)
run = {}
with open(RUN_FILE, "r", encoding="utf-8") as f:
    for line in f:
        query_id, _, doc_id, rank, score, _ = line.strip().split()
        run.setdefault(query_id, {})[doc_id] = float(score)

# Define the evaluator
evaluator = pytrec_eval.RelevanceEvaluator(qrels, {'map', 'P_5', 'P_10', 'P_15', 'P_20'})

# Evaluate
results = evaluator.evaluate(run)

# Print results per query
for query_id, metrics in results.items():
    print(f"Query {query_id}")
    for metric, value in metrics.items():
        print(f"  {metric}: {value:.4f}")

# Print average across queries
print("\nAverages:")
average = pytrec_eval.compute_aggregated_measurements(results)
for metric, value in average.items():
    print(f"  {metric}: {value:.4f}")
