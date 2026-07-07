#!/usr/bin/env python3
"""Python 3 baseline for the NLP benchmark (stdlib only: collections.Counter, re).

Run gencorpus.py first, then:  python bench_python.py
Reports best-of-5 wall time per workload. Compare against bench_softanza.ring.
"""
import math
import os
import re
import time
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))


def rd(name):
    with open(os.path.join(HERE, name), encoding="utf-8") as f:
        return f.read()


def timed(fn, reps=5):
    best = 1e9
    r = None
    for _ in range(reps):
        t = time.perf_counter()
        r = fn()
        best = min(best, (time.perf_counter() - t) * 1000)
    return best, r


corpus = rd("corpus.txt")
entities = rd("entities.txt")
docA = rd("docA.txt")
docB = rd("docB.txt")

# 1) word frequency top-20 (folded), chunked to mirror the streaming feed
chunks = corpus.split(". ")


def wordfreq():
    c = Counter()
    for ch in chunks:
        c.update(ch.lower().split())
    return c.most_common(20)


t, r = timed(wordfreq)
print(f"wordfreq top20      : {t:8.2f} ms   (top={r[0]})")


# 2) cosine similarity docA vs docB (folded)
def cosine():
    a, b = Counter(docA.lower().split()), Counter(docB.lower().split())
    dot = sum(a[k] * b[k] for k in a)
    na = math.sqrt(sum(v * v for v in a.values()))
    nb = math.sqrt(sum(v * v for v in b.values()))
    return 0 if na == 0 or nb == 0 else dot / (na * nb)


t, r = timed(cosine)
print(f"cosine similarity   : {t:8.2f} ms   (sim={r:.4f})")


# 3) collocations / PMI top-10 bigrams (min count 5, folded)
def collocations():
    toks = corpus.lower().split()
    uni = Counter(toks)
    bi = Counter(zip(toks, toks[1:]))
    n = len(toks)
    scored = []
    for (w1, w2), c in bi.items():
        if c < 5:
            continue
        scored.append((math.log(c * n / (uni[w1] * uni[w2])), w1, w2))
    scored.sort(reverse=True)
    return scored[0]


t, r = timed(collocations)
print(f"collocations PMI    : {t:8.2f} ms   (top={r[1]} {r[2]})")


# 4) NER extraction (emails + urls + ipv4) over the entity text
email_re = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
url_re = re.compile(r"https?://[A-Za-z0-9./?=&_%#~:+-]+")
ip_re = re.compile(r"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")


def ner():
    return (len(email_re.findall(entities)),
            len(url_re.findall(entities)),
            len(ip_re.findall(entities)))


t, r = timed(ner)
print(f"NER emails+urls+ips : {t:8.2f} ms   (counts={r})")

# 5) sentence segmentation -- naive stdlib regex (NOT UAX#29; different semantics)
sent_re = re.compile(r"(?<=[.!?])\s+")


def sentences():
    return len(sent_re.split(corpus))


t, r = timed(sentences)
print(f"sentence split(regex): {t:8.2f} ms   (n={r})")

# 6) CJK overlapping bigrams (dictionary-free CJK search tokenization)
cjk = rd("cjk.txt")


def cjk_bigrams():
    out = []
    for run in cjk.split(" "):
        if len(run) <= 1:
            out.append(run)
        else:
            out.extend(run[i:i + 2] for i in range(len(run) - 1))
            out.append(run[-1])  # trailing unigram, matching Softanza's scheme
    return len(out)


t, r = timed(cjk_bigrams)
print(f"CJK bigrams         : {t:8.2f} ms   (tokens={r})")

# stemming has no Python stdlib baseline (NLTK's Snowball is pure-Python, ~10-50x
# slower than the C libstemmer Softanza vendors) -- see bench_softanza.ring.
print("stemming            :   (no stdlib baseline; Softanza uses C Snowball)")
