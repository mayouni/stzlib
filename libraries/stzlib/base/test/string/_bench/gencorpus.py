#!/usr/bin/env python3
"""Generate the shared benchmark corpus for the Softanza-vs-Python NLP bench.

Deterministic (fixed seed) so both benchmark runners see identical input and
results are comparable run-to-run. Writes into this script's own directory:

    corpus.txt    ~2.7 MB / 600k Zipf-distributed word tokens (word/char/n-gram
                  frequency, collocations)
    entities.txt  ~1.2 MB of entity-rich text (NER extraction)
    docA.txt/docB.txt  two moderately-overlapping documents (cosine similarity)

Run once before the benchmarks:  python gencorpus.py
The generated .txt files are gitignored (regenerate rather than commit them).
"""
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
random.seed(42)

# Zipf-ish vocabulary so word frequencies are realistic.
vocab = ["the", "of", "and", "to", "in", "a", "is", "that", "for", "it", "as",
         "was", "with", "machine", "learning", "data", "model", "neural",
         "network", "training", "vector", "softanza", "engine", "string",
         "unicode", "python", "performance", "benchmark", "quick", "brown",
         "fox", "lazy", "dog", "jumps", "over", "system", "process", "memory"]
weights = [1.0 / (i + 1) for i in range(len(vocab))]

words = random.choices(vocab, weights=weights, k=600000)
out = []
for i, w in enumerate(words):
    out.append(w)
    out.append(". " if i % 12 == 11 else " ")
text = "".join(out)
with open(os.path.join(HERE, "corpus.txt"), "w", encoding="utf-8") as f:
    f.write(text)
print("corpus.txt   ", len(text), "bytes,", len(words), "tokens")

block = ("Contact a.b@example.com or admin_42@mail.co.uk. See "
         "https://softanza.org/docs?x=1 and http://example.net/path#frag. "
         "Server 192.168.1.1 and 10.0.0.255 up since 2024-01-15 at 14:30:00. "
         "Call +1 (555) 123-4567 or 555.867.5309. Love #NLP by @softanza! "
         "Paid $1,234.56 today. Retry 3/4/2024 at 9:05.\n")
with open(os.path.join(HERE, "entities.txt"), "w", encoding="utf-8") as f:
    f.write(block * 4000)
print("entities.txt ", os.path.getsize(os.path.join(HERE, "entities.txt")),
      "bytes, 4000 blocks")

docA = " ".join(random.choices(vocab[:25], weights=weights[:25], k=8000))
docB = " ".join(random.choices(vocab[10:], k=8000))
with open(os.path.join(HERE, "docA.txt"), "w", encoding="utf-8") as f:
    f.write(docA)
with open(os.path.join(HERE, "docB.txt"), "w", encoding="utf-8") as f:
    f.write(docB)
print("docA.txt/docB.txt  8000 words each")
