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
| 5 | Sentence segmentation (UAX#29) | `NumberOfSentences` | corpus.txt (~50k capitalized sentences) |
| 6 | CJK bigram tokenization | `WordsForSearch` | cjk.txt (~150k CJK chars) |
| 7 | Stemming (Snowball English) | `Stemmed` | corpus.txt |

corpus.txt capitalizes each sentence's first word on purpose — UAX#29 SB8
suppresses breaks before a lowercase word, so an all-lowercase corpus reads as
ONE sentence (correct, but doesn't exercise segmentation). Each reports best-of-5. **Windows Ring `clock()` has ~10–15 ms resolution** —
treat sub-15 ms numbers (e.g. cosine) as noise.

## Last measured (2026-07-07, Opus session; Ring 1.27, Python 3.13)

| Workload | Softanza | Python | Note |
|----------|---------:|-------:|------|
| Word frequency top-20 | 168 ms | 59 ms | 2.8× |
| Cosine similarity | ~5 ms | ~1 ms | both at noise floor |
| Collocations / PMI | 275 ms | 123 ms | 2.2× |
| NER emails+urls+ips | 584 ms | 25 ms | PCRE2 vs C `re` |
| Sentences (UAX#29) | 337 ms | 28 ms | Softanza n=48072 (real UAX#29) vs regex n=50001 (naive) |
| CJK bigrams | 237 ms | 19 ms | incl. 150k-item Ring list build |
| Stemming 600k words | ~600–900 ms | — | C Snowball; no Python stdlib baseline |

Python's `Counter`/`re`/`str` are hand-tuned C, so it stays ahead in raw ms;
Softanza is the only Ring-native option that is both Unicode-correct and free of
O(n²) cliffs. The sentence and CJK rows are not apples-to-apples on *semantics*:
Softanza runs full UAX#29 Sentence_Break (skips single-letter-initial periods, so
48072 vs the naive regex's 50001) and emits a trailing CJK unigram per run.

Bugs found & fixed **via this harness**: PCRE2 re-validating the whole subject on
every match (extract/replace O(matches × input) — a 140k-match extract 103 s →
0.22 s); per-token allocation in every frequency tokenizer (probe-first + ASCII
fast-fold, ~4×); and `_SplitNullDelimited` O(n²) in Words()/StemmedWords()/
WordsForSearch() (150k CJK bigrams 61 s → 0.13 s via a native-list bridge).
