# NLP benchmark harness — Softanza vs Python

Head-to-head wall-clock benchmark of Softanza's engine-backed text-analytics
methods against Python 3's C-implemented stdlib (`collections.Counter`, `re`) on
an identical corpus. Used to catch performance regressions and to keep the
Softanza-vs-Python gap honest.

## Running

```sh
python gencorpus.py        # 1. generate the shared corpus (deterministic, seed=42)
python bench_python.py     # 2. Python baseline (stdlib only)
ring bench_softanza.ring   # 3. Softanza — RUN FROM THIS DIRECTORY
```

The Ring runner must be run from this `_bench/` directory: it loads
`../../../stzBase.ring` and reads the corpus files by relative path, and the Zig
engine DLLs resolve relative to the run location. Build the engine first if you
haven't (`cd libraries/stzlib/engine && zig build -Dring=D:/ring127`).

The generated `*.txt` corpus (~4 MB) is gitignored — regenerate it rather than
committing it.

## Workloads

| # | Workload | Softanza method | Corpus |
|---|----------|-----------------|--------|
| 1 | Word frequency, top-20 (folded) | `stzWordStream.TopWords` | corpus.txt (2.7 MB / 600k tokens) |
| 2 | Cosine similarity of two docs | `CosineSimilarityWithCS` | docA/docB (8k words each) |
| 3 | Collocations / PMI, top-10 bigrams | `CollocationsCS(5,10,0)` | corpus.txt |
| 4 | NER: emails + URLs + IPv4 | `ExtractEmails/URLs/IPv4Addresses` | entities.txt (1.2 MB) |

Each reports best-of-5. **Windows Ring `clock()` has ~10–15 ms resolution** —
treat sub-15 ms numbers (e.g. cosine) as noise.

## Last measured (2026-07-06, Opus session; Ring 1.27, Python 3.13)

| Workload | Softanza | Python | Ratio |
|----------|---------:|-------:|------:|
| Word frequency top-20 | 106 ms | 59 ms | 1.8× |
| Cosine similarity | ~10 ms | ~1 ms | (both at noise floor) |
| Collocations / PMI | 203 ms | 124 ms | 1.6× |
| NER emails+urls+ips | 332 ms | 27 ms | 12× |

Python's `Counter`/`re` are hand-tuned C, so it stays ahead; Softanza is the only
Ring-native option that is both Unicode-correct and free of the O(n²) cliffs.
Two catastrophic bugs were found and fixed via this harness: PCRE2 re-validating
the whole subject on every match (extract/replace were O(matches × input) — a
140k-match extract went 103 s → 0.22 s), and per-token allocation in every
frequency tokenizer (probe-first + ASCII fast-fold, ~4× on word frequency).
