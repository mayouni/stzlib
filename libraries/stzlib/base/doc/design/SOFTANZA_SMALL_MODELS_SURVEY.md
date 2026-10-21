# Small open models for Softanza — the survey, the floors, and what has been MEASURED

**Date**: 2026-10-21 · **Plane**: stzlib-intelligence · **Companion to**: `SOFTANZA_MODEL_FLOW.md` (§13 is the faculty catalogue this feeds), `SOFTANZA_DOCUMENT_INTELLIGENCE_MEMO.md`.
**Detail**: `survey/` holds the five research reports this page distils (B1 text/NLP/LLMs, B2 code/maths/tabular/time series/security/geo, B3 speech/vision/OCR/document VLMs, B4 Datalab/Indra, D Docling) and the Compass digest. Each report tags every claim as read-live, read-in-code or not-verified, and ends with a *verified vs not-verified* list. **They were produced by research agents reading live model cards on 2026-10-21; the licences and sizes that matter most were then re-fetched by the author of this page** (Granite-Docling, the layout model, Indra, Qwen3, Granite-4.0-350m, Qwen3-0.6B: all matched). Nothing else is promoted from "reported" to "verified" here.

**The rule that keeps this list honest**: *a model that does not beat its floor earns no place.* Of the several dozen models surveyed, **8 files have been run** and **7 models have been measured against a floor**. Everything else is a candidate, with the engine work it would cost.

---

## 1. What has been measured (golden set v1, 2026-10-21; `base/test/faculty/results/measurements.zmdl.txt`)

| faculty | floor (score) | model | score | verdict |
|---|---|---|---|---|
| retrieve (top-4 contains the right article; n=12) | word-IDF (0.50) | **all-MiniLM-L6-v2** (Apache-2.0, 25 MB, BERT) | **1.00** | **earns its place** (+0.50) |
| rerank (top-1; n=12) | stem-overlap (0.42) | jina-reranker-v1-turbo-en (Apache-2.0, 42 MB) | 0.33 | **loses to its floor** |
| triage-extract ({product, severity}; n=36, independent author) | keyword rules (0.56) | generated: SmolLM2-135M 0.19 · Qwen3-0.6B 0.33 · Granite-4.0-350m 0.28 · Qwen2.5-Coder-0.5B 0.14 — **read by probability**: Qwen3-0.6B 0.39 · Qwen2.5-Coder-0.5B 0.25 · SmolLM2 0.11 · Granite 0.11 | ≤ 0.39 | none earns a place |
| brief (≤ 9 words, keeps the keyword; n=36) | first clause (0.69) | SmolLM2 0.03 · Qwen3-0.6B 0.56 · Granite-350m 0.47 · Qwen2.5-Coder-0.5B 0.56 | ≤ 0.56 | none earns a place |
| kind (bug/billing/other; n=36) | keyword rules (0.69) | generated: SmolLM2 0.42 · Qwen3-0.6B 0.31 · Granite-350m 0.42 · Qwen2.5-Coder-0.5B 0.50 — **read by probability** (`StzOptionProbabilities`): **Qwen2.5-Coder-0.5B 0.64** · Granite 0.47 · Qwen3-0.6B 0.42 · (SmolLM2 refused: "Billing" and "Bug" share a first token) | ≤ 0.64 | none earns a place — **but reading beats generating for every model that works (+0.05 to +0.14), and the best is within two items of the floor** |

**At 1B the picture changes (Granite-4.0-1b, Apache-2.0, 1.74 GB Q8):** extraction **0.72 read by probability against the floor's 0.56 — the first model to strictly beat a floor on a generative faculty** (generated it only ties, 0.56); classification 0.67 both ways against the floor's 0.69 (a tie within noise); brief 0.53 against 0.69 (loses). The registry now selects `granite-1b-choice` for extraction and the flow guard exercises that path (44/44). **Reading probabilities, not generating, is what made the difference**: the same model generating is no better than the floor.

**Qwen2.5-Coder-1.5B (the one that computes on K4) on the same sets:** extraction **0.61 generated, 0.64 read** against the floor's 0.56 (it earns a place, below Granite-1b's 0.72); classification 0.64 generated / 0.56 read against 0.69 (no); brief 0.50 (no). So **two 1B-class models beat the extraction floor and none beats the classification or brief floors** — hand-written rules for a small closed vocabulary are strong, and a model has to be good to displace them.

**Two corrections to earlier figures, stated plainly.** (1) The first Qwen3-0.6B rows (extract 0.25, brief 0.25, kind 0.33) were measured while the engine encoded `<think>` / `</think>` as three text pieces instead of Qwen3's single added tokens (fixed in 17aeac094); with the fix they are 0.33, 0.56 and 0.31. (2) The jina-reranker and MiniLM rows are unaffected (separate encoder tokeniser).

Not yet measured on these sets: **Qwen3-1.7B / 4B-2507** and **Granite-4.2-3B** — waiting on a download (and disk). The honest reading today: **below roughly 1B parameters, a model does not beat a competent hand-written floor on these tasks; the places a small model wins are embedding retrieval, and — at 1B, read by probability — extraction.** Two cautions that travel with the numbers: the floors were *not* written to the golden sets (the original 20 tickets, which the floor's author read, score 1.0 and are kept only as a labelled dev set), and the goldens are small (n = 12 to 36) — a score difference under ~0.1 is inside the noise.

## 2. Engine status of each architecture (`neural_gen.zig`, `neural_embed.zig`)

| architecture | status | evidence |
|---|---|---|
| llama, qwen2, smollm | runs | in use since 2026-07 |
| **qwen3** | **runs since 98d5eb732** (q/k RMSNorm + head width ≠ hidden/heads) | `engine_qwen3_narrated` 13/13, behavioural |
| **granite** (dense) | **runs since 703cfc051**; hybrid / MoE / irregular stacks are *refused* | `engine_granite_narrated` 9/9, behavioural |
| k-quants (Q4_K_M …) | **run** (ggml's matmul reads them) | Qwen3-0.6B-Q4_K_M passes the same guard |
| BERT-family encoders, cross-encoder, NER head | run | numpy parity 1.64e-7 |
| gemma3/4, phi3/4, mistral3, smollm3, qwen3.5 (gated delta-net), lfm2, jais (k2-horizon), DeBERTa/ModernBERT | **do not run** | per-arch ports (survey B1/B2) |
| vision tower, audio encoder, embeddings-into-decoder, cross-attention, beam search | **missing** | B3, D |

## 3. The shortlist by domain (licence-permissive, ≤ ~3 GB quantised; **candidates, none measured unless stated**)

| domain | floor in Softanza today | best candidates (licence, quantised size, arch) | what it costs |
|---|---|---|---|
| chat / summarise / classify / extract | extractive summary, keyword rules, `stzLLMFunction` | **Granite-4.0-1b** (Apache, 0.95 GiB Q4_K_M, runs now) · **Qwen3-1.7B / 4B-2507** (Apache, 1.0 / 2.3 GiB, runs now) · SmolLM2-1.7B (Apache, 1.0 GiB, runs now) · Granite-4.2-3B (Apache, 2.1 GiB, runs if dense) | download + measure; **start with the 1–4B class, not <1B** |
| code | the engine computes (K4 oracle) | Qwen2.5-Coder-1.5B (Apache; **5–6 of 20 on K4**, first model that computes) · Qwen3-4B-2507 · Granite-4.2-3B (LiveCodeBench v6 69.7 per its card). *Qwen2.5-Coder-3B is `qwen-research`, not Apache.* | measure on the K4 + a Softanza task set |
| maths | exact arithmetic tower, autodiff, simplex — **the oracle, not a competitor** | DeepSeek-R1-Distill-Qwen-1.5B (MIT, runs) | n/a |
| embeddings (multilingual) | lexical | **Qwen3-Embedding-0.6B** (Apache) · multilingual-e5-small (MIT, tags Hausa) · bge-m3 (MIT) · LaBSE (Apache, 109 languages incl. Hausa/Yoruba) | E3 (last-token/CLS pooling) + E4 (unigram tokenizer) |
| reranking | lexical IDF / stem overlap | bge-reranker-v2-m3 (Apache) · Qwen3-Reranker-0.6B (Apache) | E3/E4 — and **measure: the English Jina reranker lost to its floor** |
| language ID | engine detector (6 languages + Arabic script) | **GlotLID v3** (Apache + notices; Zarma `dje_Latn` F1 0.994, Hausa 0.989) · CommonLingua (Apache, 2.35M params) | a pure-Zig fastText reader |
| translation | **none** | NLLB / Jina-v3 / fastText-langid are **CC-BY-NC — excluded** | an honest gap: no permissive candidate verified |
| NER / sentiment | gazetteer+rules (English) / VADER (English) | bert-base-NER (MIT, in use) · lxyuan multilingual sentiment (Apache; fr, ar) · *Masakhane NER has no declared licence — not adoptable* | E5 (N-class head) |
| time series | moving average, OLS, FFT, z-score — **no forecasting** | **TTM r3** (Apache, 1.4M params) · **Toto-2.0-22m** (Apache, decoder-only) · *TimesFM 3.0, TabPFN ≥ 2.5 are non-commercial* | new graph (TTM) / near the decoder (Toto) |
| tabular | kNN, logistic, ID3, k-means | TabICL (licence unverified) | none; the floor is weak |
| text → record / SQL | `stzOutputSchema` + `stzLLMFunction`; no NL→SQL | NuExtract-2.0-2B (MIT) | accept `qwen2vl` arch string for text |
| security (content) | structural rules only | Qwen3Guard-Gen-0.6B (Apache, runs) · *Prompt Guard / ProtectAI: DeBERTa or Llama licence — blocked* | measure |
| geo | country-name resolution | **no model earns a place** | assemble the fuzzy gazetteer floor first |
| speech → text | SAPI closed grammar (100 %), dictation 66.7 % (**fails its own gate**) | **whisper.cpp** (MIT; core ~520 KB; also runs Parakeet) · **Qwen3-ASR-0.6B** (Apache; French + Arabic; Qwen3 decoder) | vendor with the C++ static-init patches; or encoder + embedding injection + 2nd slot |
| text → speech | SAPI voices (en, fr; no Arabic) | **none permissive**: Piper successor GPL-3, kokoro.cpp links espeak-ng (GPL), Supertonic OpenRAIL-M | none now |
| OCR | none; `Windows.Media.Ocr` measured (fr exact, Arabic splits words) | Tesseract (Apache; fra 1.1 MB, ara 1.4 MB) · PP-OCRv6 (Apache, ONNX) · **Indra / Surya / Chandra: revenue-capped OpenRAIL-M ($20M / $5M / $2M, no-compete) — not permissive, off the default path** | Tesseract: vendor with static-init care |
| document VLM | none | **Granite-Docling-258M** (Apache; decoder = SmolLM2-135M shape) · SmolVLM-256M (Apache) | SigLIP tower + connector + embeddings-into-decoder |
| PDF text | **none** | n/a — a native parser is the floor | see the document memo |

## 4. What this changes in the plan

1. **The next models to measure are in the 1–4B class**, because <1B was measured and lost. The cheapest decisive step: Granite-4.0-1b and Qwen3-1.7B on the three generative golden sets (≈ 1 GB each at Q8 — each a download that needs a stated filename, source and size first).
2. **The registry already does the right thing with this result**: it selects the floor where no model won, and MiniLM where it did — so the library is *better today* than a "use the model" default would have been.
3. **Floors are an asset to invest in**, not a placeholder: three of the five generative floors beat every small model, and the others (translation, PDF, mel features, content classification, forecasting) are *refuses*, i.e. the first thing a model must beat.
4. **Retrieval is the strongest case for the layer today**: one cheap model, a decisive gain, and a documented composition effect (a weak floor reranker can undo a good first stage).

*Verified vs not verified*: see the end of each report in `survey/`. In particular **not verified**: every benchmark number quoted from a model card (vendor-stated, not reproduced); TabICL's weights licence (the repo returned 401); whether FIM tokens are control tokens in the Qwen GGUFs; GlotLID's Zarma row beyond the part of the table read; the official Granite-Docling GGUF sizes.
