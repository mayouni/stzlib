# B1 -- small open models: text LLMs (a) and text/NLP specialists (b)

Date of reading: 2026-10-21. Read-only research. Nothing downloaded, installed, or written in any repository.

**Ref read (CLAUDE.md read-only rule).** Engine and library facts below were read from the working tree `D:\GitHub\_wti`, branch `intelligence/model-flow`, HEAD `a6a59d4f6` (2026-09-26), which has uncommitted changes (`stzNeuralModel.ring`, `engine/build.zig`). This is NOT `origin/main`. Anything claimed about "the engine today" is a claim about that tree and was read, not run.

**Sizes.** GiB or MiB = bytes / 2^30 or 2^20, taken from the Hugging Face `/api/models/<repo>/tree/main` listing (exact bytes) unless a cell says `~` (the fetch tool's own rounding, unit not guaranteed) or `est` (computed, not read). "GGUF from" names the publisher. Licence = what the HF `license` tag / cardData says; the card text was read only where stated.

---

## 0. What the engine really accepts (read from `neural_gen.zig`, `neural_embed.zig`)

Decoder (`neural_gen.zig`):
- Whitelist in `neural_model_has_generator()`: `general.architecture` in {llama, qwen2, qwen3, smollm}. Tensor names expected: `blk.N.attn_norm`, `attn_q/k/v` (+ optional biases), `attn_output`, `ffn_norm`, SwiGLU FFN, `output_norm`, `output.weight` else tied `token_embd`. RoPE: NEOX for qwen2/qwen3, NORMAL for the rest; `rope_ext` is called with **null freq-factors** (so no `rope_freqs.weight`, no YaRN/LongRoPE/llama3 scaling).
- **FINDING: `qwen3` is whitelisted, but the file contains no handling of `attn_q_norm` / `attn_k_norm`** (grepped the whole `engine/` and `base/` tree: the only hit is the unrelated word match in this one file's whitelist; no `q_norm`/`k_norm` anywhere; no qwen3 test exists under `base/test/neural`). Every Qwen3 model has per-head RMSNorm on Q and K before RoPE. Reading the code, a Qwen3 GGUF would load and generate, but with the QK-norm missing the output should be wrong. I did NOT run it. Treat "Qwen3 runs today" as **unproven and probably false** until a parity test exists. This one gap also gates Qwen3-Embedding-0.6B and Qwen3-Reranker-0.6B.
- Tokenizer: GPT-2 byte-level BPE from `tokenizer.ggml.tokens` + `.merges`; CONTROL tokens (type 3) matched literally; the pre-tokenizer is a hand-written approximation (leading-space glue, letter runs where every byte >= 0x80 counts as a letter, digit runs, punctuation runs). It does not read `tokenizer.ggml.model` or `tokenizer.ggml.pre`. So: exact for SmolLM2/Qwen-style, approximate for Llama-3 / tiktoken-style pre-tokenizers (digit grouping, contractions differ). Anything with `tokenizer.ggml.model = llama` (SentencePiece, no merges: TinyLlama, Gemma, Mistral-7B-style, EuroLLM) does not work.
- KV cache, greedy/temperature/top-p sampling, GBNF constrained decoding (`gbnf_machine.zig`), chat reuse all exist.

Encoder (`neural_embed.zig`): BERT-family forward (learned positions or ALiBi, GELU or GEGLU, post-LN), mean pooling + L2 norm only (no CLS/last-token pooling, no Dense head), WordPiece in two schemes (classic `##` and SentencePiece-metaspace written as greedy longest-match over the vocab, NOT a Viterbi unigram), `ner.classifier.{weight,bias}` token head (convention of `cstr/bert-base-NER-GGUF`), `cls.{weight,bias}` single-score cross-encoder head. Needs `token_types.weight`.

Cheapest engine work, ranked by models unlocked:
- **E1 QK-norm** (per-head RMSNorm on Q,K before RoPE; ~10 lines + a parity guard): Qwen3 0.6B/1.7B/4B/4B-2507, Qwen3-Embedding-0.6B, Qwen3-Reranker-0.6B.
- **E2 `granite` arch** (llama graph + four scalar multipliers from the GGUF: embedding scale, attention scale, residual scale, logit scale): Granite 4.0 350M/1B/micro, 4.1-3B, 4.2-3B. GPT-2-style BPE, so the tokenizer fits (pre-tokenizer fidelity not verified).
- **E3 pooling modes**: last-token and CLS pooling, an embed-mode decoder forward (no lm_head), and a way to read the next-token logits of two tokens ("yes"/"no") for Qwen3-Reranker.
- **E4 SentencePiece-unigram (Viterbi over `tokenizer.ggml.scores`)** + `<s>`/`</s>` as CLS/SEP: bge-m3, multilingual-e5, bge-reranker-v2-m3, paraphrase-multilingual, XLM-R NER/sentiment heads.
- **E5 multi-class sequence-classification head** (generalise `cls.weight` from one score to N labels): nlptown / lxyuan / papluca-style models.
- **E6 per-arch ports**: phi3 (fused QKV + fused gate/up + LongRoPE), mistral3 (YaRN + tekken tokenizer), smollm3 (NoPE layers), llama3 rope scaling (`rope_freqs.weight`).
- Not worth it soon: gemma3/gemma4 (norms, softcap, sliding window, per-layer embeddings), qwen35 (Gated DeltaNet hybrid), lfm2 (conv hybrid), olmo2, minicpm, k2-horizon (Jais-3, unknown).

---

## (a) General small instruct LLMs

### a.1 Licence Apache-2.0 / MIT, <= ~3 GB quantised

| candidate | HF repo (GGUF from) | licence | params | Q8_0 | Q4_K_M | arch (GGUF) | ctx | languages | engine-runnable? | notes |
|---|---|---|---|---|---|---|---|---|---|---|
| SmolLM2-135M-Instruct | HuggingFaceTB/SmolLM2-135M-Instruct (+ vendor GGUF) | apache-2.0 | 135M | (in use) | (in use) | llama | 8192 | en | YES (in use) | measured ~0 on code; floor of the family |
| SmolLM2-360M-Instruct | HuggingFaceTB/SmolLM2-360M-Instruct-GGUF (vendor, Q8 only); bartowski for others | apache-2.0 | 362M | 368.5 MiB | 258.1 MiB (bartowski) | llama | 8192 | en | YES | cheap router/classifier tier |
| SmolLM2-1.7B-Instruct | HuggingFaceTB/SmolLM2-1.7B-Instruct; GGUF bartowski/SmolLM2-1.7B-Instruct-GGUF | apache-2.0 | 1.71B | 1.70 GiB | 0.98 GiB | llama | 8192 | en | YES | best of the already-running family for chat; HF card says en only |
| Qwen2.5-0.5B / 1.5B-Instruct | Qwen/Qwen2.5-1.5B-Instruct-GGUF (vendor) | apache-2.0 | 0.49B / 1.54B | ~1.76 (1.5B) | ~1.04 (1.5B) | qwen2 | 32k | 29+ incl. fr, ar | YES (in use) | known-good |
| DeepSeek-R1-Distill-Qwen-1.5B | deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B (card MIT); GGUF unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF (its card says apache-2.0) | MIT (deepseek-ai card) | 1.78B | 1.76 GiB | 1.04 GiB | qwen2 | 131072 | en/zh | YES (arch qwen2) | emits long `<think>`; poor fit for short structured tasks; use only if reasoning on a budget |
| **Qwen3-0.6B** | Qwen/Qwen3-0.6B-GGUF (vendor, Q8_0 only); unsloth/Qwen3-0.6B-GGUF | apache-2.0 | 0.60B | 609.8 MiB | 378.3 MiB (unsloth) | qwen3 | 40960 (32k native) | 119 languages (per Qwen3 card; not re-read here) | **NO until E1** (QK-norm) | thinking/non-thinking switch |
| **Qwen3-1.7B** | Qwen/Qwen3-1.7B-GGUF (vendor, Q8_0 only); unsloth for K-quants | apache-2.0 | 1.72B | 1.71 GiB | 1.03 GiB (unsloth) | qwen3 | 40960 | 119 | **NO until E1** | strongest candidate in its size class for the 1.5B-coder gap |
| **Qwen3-4B** | Qwen/Qwen3-4B-GGUF (vendor) | apache-2.0 | 4.02B | 3.99 GiB (over 3 GB) | 2.33 GiB | qwen3 | 40960 | 119 | **NO until E1** | only Q4_K_M fits the size filter |
| **Qwen3-4B-Instruct-2507** | Qwen/Qwen3-4B-Instruct-2507 ; GGUF unsloth/Qwen3-4B-Instruct-2507-GGUF | apache-2.0 | 4.02B | 3.99 GiB (over) | 2.33 GiB | qwen3 | 262144 | multilingual | **NO until E1** | non-thinking, newest Qwen3 small dense (2025-08); no newer small dense Qwen exists (see below) |
| Qwen3-4B-Thinking-2507 | Qwen/Qwen3-4B-Thinking-2507 | apache-2.0 | 4.02B | ~3.99 (est, same shape) | ~2.33 (est) | qwen3 | 262144 | multilingual | NO until E1 | reasoning only |
| **Granite-4.0-350m** | ibm-granite/granite-4.0-350m-GGUF (vendor) | apache-2.0 | 0.35B | 360.6 MiB | 226.0 MiB | granite | 32768 | 12 (en de es fr ja pt ar cs it ko nl zh; list read from the 4.1 card) | **NO until E2** | smallest credible modern tier |
| **Granite-4.0-1b** | ibm-granite/granite-4.0-1b-GGUF (vendor) | apache-2.0 | 1.63B | 1.62 GiB | 0.95 GiB | granite | 131072 | 12 | **NO until E2** | |
| **Granite-4.0-micro (3B)** | ibm-granite/granite-4.0-micro-GGUF (vendor) | apache-2.0 | 3.40B | 3.37 GiB (over) | 1.96 GiB | granite | 131072 | 12 | NO until E2 | |
| **Granite-4.1-3B** | ibm-granite/granite-4.1-3b ; GGUF unsloth/granite-4.1-3b-GGUF (no vendor GGUF seen) | apache-2.0 | 3.40B | est 3.4 GiB (over) | est 1.96 GiB | granite | 131072 | 12 | NO until E2 | dense GQA/RoPE/SwiGLU/RMSNorm, 40 layers, d=2560; card (2026-04-29): IFEval 82.3, GSM8K 86.9, BFCL v3 60.8; targets summarisation, classification, extraction, RAG, tool calling |
| **Granite-4.2-3B** | ibm-granite/granite-4.2-3b ; GGUF ibm-granite/granite-4.2-3b-GGUF (vendor) | apache-2.0 | 3.66B (GGUF total; separate lm_head) | 3.63 GiB (over) | 2.09 GiB | granite | 131072 | 12 | NO until E2 | released 2026-08-25; native reasoning with three modes (full / non-thinking / low-effort); IFBench 74.3, BFCL v4 52.4. Best "assistant" in this list if one model slot is spent on a 3B |
| Phi-4-mini-instruct | microsoft/Phi-4-mini-instruct ; GGUF bartowski/microsoft_Phi-4-mini-instruct-GGUF | mit | 3.84B | 3.80 GiB (over) | 2.32 GiB | phi3 | 131072 | 24 incl. ar, fr, en | NO: needs E6 (phi3: fused qkv/ffn, LongRoPE) | bartowski card did not list licence; MIT is from the Microsoft repo |
| Ministral-3-3B-Instruct-2512 | mistralai/Ministral-3-3B-Instruct-2512 (FP8 weights); GGUF unsloth/Ministral-3-3B-Instruct-2512-GGUF | apache-2.0 | 3.43B incl. vision | 3.40 GiB (over) | 2.00 GiB (+0.78 GiB mmproj, unneeded) | mistral3 | 262144 | en fr es de it pt nl zh ja ko ar | NO: E6 (mistral3, YaRN, tekken) | |
| SmolLM3-3B | HuggingFaceTB/SmolLM3-3B ; GGUF ggml-org/SmolLM3-3B-GGUF | apache-2.0 | 3.08B | 3.05 GiB (borderline) | 1.78 GiB | smollm3 | 65536 | en fr es it pt zh ar ru | NO: arch string `smollm3` is not whitelisted; NoPE layers | fully open recipe; the engine's `smollm` whitelist entry is a different string |
| Gemma 4 E2B-it | google/gemma-4-E2B-it ; GGUF unsloth/gemma-4-E2B-it-GGUF | **apache-2.0** | 2.3B effective / 5.1B stored | 4.70 GiB (over) | 2.89 GiB | gemma4 | 131072 | not listed in API | NO: new arch | surprise: Gemma 4 is Apache, not "Gemma terms"; multimodal; Gemma 3 is still `gemma` licence |
| Qwen3.5-0.8B / 2B / 4B | Qwen/Qwen3.5-{0.8B,2B,4B}; GGUF unsloth/Qwen3.5-*-GGUF | apache-2.0 | 0.87B / 1.88B / ~4B | 0.76 / 1.87 / 4.17 GiB | 0.50 / 1.19 / 2.55 GiB | qwen35 | 262144 | multimodal, multilingual | NO: Gated DeltaNet hybrid (recurrent state) + vision | released 2026-02/03; newest Qwen small tier. Qwen3.6 (27B, 35B-A3B) and Qwen3.8 (27B, 2.4T) are all >4B; Qwen-Drive-1.0-4B is a vision-language agent |
| Pleias-RAG-350M / 1B | PleIAs/Pleias-RAG-350M-gguf, PleIAs/Pleias-RAG-1B-gguf (vendor; one file each, 1B file is ~2.4 GB so likely f16) | apache-2.0 | 0.35B / 1.2B | n/a (single file) | n/a | llama | 4096 | en fr it de es | MAYBE: arch llama, tokenizer type NOT verified | RAG-with-citations specialist; French is first-class, relevant for Niger |
| Jais-3-0.9B / 3.7B | inception42/Jais-3-0.9B; GGUF IFM/Jais-3-0.9B-GGUF, IFM/Jais-3-3.7B-GGUF | apache-2.0 | 1.08B / 5.06B (GGUF totals) | 1.07 GiB / 5.02 GiB | 0.62 GiB / 2.94 GiB | **k2-horizon** (unknown) | 131072 / 524288 | ar, en only | NO: unknown arch; its card does not state layers/attention/tokenizer | only credible Arabic-first small model found (released 2026-09-29; 3.7B card: Arabic MMLU 83.3, Belebele 91.9). Dialect coverage not stated on the card |

Also checked, not usable: `microsoft/FrogNano-4B-2609`, `UserRepGen-4B`, `Sentiment-Analysis-7B` (task or size mismatch), `allenai/tmax-2b/4b`, `Bolmo-1B-Stage1` (not examined for licence or arch), `OLMo-2-0425-1B-Instruct` (apache-2.0, arch olmo2, no), `MiniCPM4-0.5B` (apache-2.0, arch minicpm, no), `EuroLLM-1.7B-Instruct` (apache-2.0, llama arch, 35 languages incl. ar/fr/hi, but SentencePiece tokenizer and no GGUF seen), `TinyLlama-1.1B-Chat-v1.0` (apache-2.0, llama, SentencePiece, 2023).

### a.2 Other licences -- "accepted only if the author agrees"

| candidate | repo | licence as stated | params | Q8_0 | Q4_K_M | arch | engine | note |
|---|---|---|---|---|---|---|---|---|
| Llama-3.2-1B-Instruct | bartowski/Llama-3.2-1B-Instruct-GGUF | `llama3.2` community licence | 1.24B | ~1.23 | ~0.75 | llama | PARTLY: arch ok, but no `rope_freqs` scaling and Llama-3 pre-tokenizer is approximated | 8 languages (en de fr it pt hi es th) |
| Llama-3.2-3B-Instruct | bartowski/Llama-3.2-3B-Instruct-GGUF | `llama3.2` | 3.21B | ~3.19 (over) | ~1.88 | llama | as above | ctx 131072 |
| Qwen2.5-3B-Instruct (and Coder-3B) | Qwen/Qwen2.5-3B-Instruct | `other`, license_name `qwen-research` | 3.09B | n/a | n/a | qwen2 | YES arch-wise | only 0.5B/1.5B/7B... are Apache; 3B is not |
| Gemma 3 270M / 1B | google/gemma-3-270m-it, ggml-org/gemma-3-1b-it-GGUF | `gemma` | 0.27B / 1.0B | -- | -- | gemma3 | NO | |
| LFM2 / LFM2.5 1.2B, 2.6B | LiquidAI/LFM2-1.2B-GGUF, LiquidAI/LFM2.5-1.2B-Instruct-GGUF | `other`, license_name `lfm1.0` | 1.17B | -- | -- | lfm2 | NO (conv hybrid) | newest LFM2.5 releases through 2026-10-20 are mostly 8B-A1B / 24B-A2B MoE and VL |
| Falcon3-3B-Instruct | tiiuae/Falcon3-3B-Instruct | `other`, `falcon-llm-license` | 3.23B | -- | -- | llama | YES arch-wise | not OSI-open |
| Tiny Aya (3.35B) | not fetched | CC-BY-NC-4.0 per a secondary article (turingpost); not verified on HF | -- | -- | -- | -- | -- | 70+ languages; non-commercial |

### a.3 Recommendation for the LLM slot

- Today, zero engine work: **SmolLM2-1.7B-Instruct** (1.70 GiB Q8) is the best already-running general instruct; **Qwen2.5-1.5B-Instruct** stays the multilingual/code floor. Neither is expected to do structured multi-step work well (measured fact in the brief).
- One small fix (E1) opens the Qwen3 line, the highest-density Apache family the engine's tokenizer and graph already nearly match. Do it with a parity guard (numpy or llama.cpp reference).
- One small port (E2, `granite`) opens Granite 4.x, which is Apache, dense, officially published as GGUF by IBM, 12 languages incl. French and Arabic, and aimed at exactly the tasks in this survey (summarise, classify, extract, RAG, tool calling). Granite-4.2-3B at Q4_K_M (2.09 GiB) is the best 3B target; Granite-4.0-1b (0.95 GiB at Q4_K_M) the best 1B target; Granite-4.0-350m (226 MiB) the router tier.
- Not worth chasing now: qwen35, gemma4, lfm2, k2-horizon (Jais-3). Revisit Jais-3-0.9B only if Arabic-first chat becomes a requirement.

---

## (b) Text / NLP specialists

### b.1 Multilingual embeddings

| candidate | repo (GGUF from) | licence | params | size (GGUF) | arch | ctx | languages | engine-runnable? | notes |
|---|---|---|---|---|---|---|---|---|---|
| all-MiniLM-L6-v2 | (in use) | apache-2.0 | 22M | (in use) | bert | 256 | en | YES | |
| **Qwen3-Embedding-0.6B** | Qwen/Qwen3-Embedding-0.6B-GGUF (vendor) | apache-2.0 | 0.60B | Q8_0 609.5 MiB; f16 1142 MiB (no Q4 from vendor) | qwen3 | 32768 | 100+ | NO until E1 + E3 (last-token pooling, query instruction prefix `Instruct: ...\nQuery:...`) | MTEB-multilingual mean 64.33 per card; dim 1024, MRL 32-1024; left padding in the reference |
| bge-m3 | BAAI/bge-m3 ; GGUF ggml-org/bge-m3-Q8_0-GGUF | mit | 568M | Q8_0 ~605 MiB (634,553,760 bytes file listed) | bert (XLM-R) | 8192 | 100+ (not enumerated on the API) | NO: E4 (unigram tokenizer) and CLS pooling | dense retrieval head only |
| multilingual-e5-small | intfloat/multilingual-e5-small ; GGUF rodion-m/multilingual-e5-small-gguf (community, fp32 only) | mit | 118M | fp32 454.3 MiB | bert (XLM-R) | 512 | 93 tags incl. **ha**, ar, fr, sw, yi... | NO: E4 | smallest multilingual option that tags Hausa; needs `query: `/`passage: ` prefixes; only fp32 GGUF seen |
| multilingual-e5-base / large | intfloat/*; many community GGUF (dinab/..., Zenabius/...) | mit | 278M / 560M | not read | bert | 512 | 93 | NO: E4 | |
| LaBSE | sentence-transformers/LaBSE ; GGUF ChristianAzinn/labse-gguf (community) | apache-2.0 | 471M | Q8_0 491.0 MiB; Q4_K_M 366.0 MiB | bert | 512 | 109, incl. ha, yo, ar, fr (tags checked) | PARTLY: classic WordPiece (the engine supports it); pooling is CLS + Dense(tanh) in the reference, GGUF drops the Dense, engine only does mean pooling -> needs E3 | translation-pair embedder (bitext mining), not a retrieval model; WordPiece makes it the cheapest multilingual encoder to support |
| nomic-embed-text-v1.5 | nomic-ai/nomic-embed-text-v1.5-GGUF (vendor) | apache-2.0 | 137M | not read | nomic-bert | 2048 | en | NO: arch (rotary + SwiGLU, no pos table) | English only; not a multilingual gain |
| snowflake-arctic-embed-m-v2.0 | Snowflake/snowflake-arctic-embed-m-v2.0 | apache-2.0 | ~305M (not read) | no GGUF checked | XLM-R-based | 8192 | 74 language tags | NO: E4 + arch | |
| gte-multilingual-base | Alibaba-NLP/gte-multilingual-base | apache-2.0 | ~305M (not read) | no GGUF checked | custom `NewModel` | 8192 | ~70 | NO: custom arch | |
| EmbeddingGemma-2 | google/embeddinggemma-2 ; GGUF ggml-org/embeddinggemma-2-GGUF, unsloth/... | **apache-2.0** | 744M | not read | embedding_gemma2 | not read | multilingual, **multimodal** (text, image, audio, video) | NO: new arch | released 2026-09-14; the older embeddinggemma-300m is licence `gemma` |
| pplx-embed-v2-late-0.6b | perplexity-ai/pplx-embed-v2-late-0.6b | mit | 594M | no GGUF checked | qwen3_5 | not read | multilingual | NO: qwen35 | |
| bitnet-embedding-270m / 0.6b | microsoft/bitnet-embedding-270m | mit | 268M | GGUF in the repo (size not read) | gemma3 | not read | 93 languages | NO: gemma3 + BitNet quant | released 2026-07-15 |

**Excluded for licence**: jina-embeddings-v3 (`cc-by-nc-4.0`), jina-embeddings-v5-omni-nano/small (`cc-by-nc-4.0`, arch eurobert), jina-reranker-v3 and v3.5 (`cc-by-nc-4.0`).

### b.2 Rerankers

| candidate | repo (GGUF from) | licence | params | size | arch | ctx | languages | engine-runnable? | notes |
|---|---|---|---|---|---|---|---|---|---|
| jina-reranker-v1-turbo-en | (in use) | apache-2.0 | 38M | (in use) | jina-bert-v2 | 8192 | en | YES | |
| cross-encoder/ms-marco-MiniLM-L6-v2 | cross-encoder/ms-marco-MiniLM-L6-v2 | apache-2.0 (not re-checked live in this survey) | 22M | no GGUF checked | BertForSequenceClassification | 512 | en | YES if converted to the `cls.weight` convention | listed from background knowledge; verify before use |
| **bge-reranker-v2-m3** | BAAI/bge-reranker-v2-m3 ; GGUF gpustack/bge-reranker-v2-m3-GGUF (community) | apache-2.0 | 568M | Q8_0 606.2 MiB; Q4_K_M 418.1 MiB | bert (XLM-R) | 8192 | multilingual | NO: E4 | the standard multilingual cross-encoder; reuses the existing `cls.weight` path |
| bge-reranker-base / large | BAAI/*; community GGUF | apache-2.0 per BAAI convention (not re-read) | 278M / 560M | not read | XLM-R | 512 | zh/en | NO: E4 | |
| **Qwen3-Reranker-0.6B** | Qwen/Qwen3-Reranker-0.6B ; GGUF community only (DevQuasar, mradermacher, dengcao...; the vendor GGUF URL returned 401) | apache-2.0 | 0.60B | not read (~0.6 GiB Q8 est) | qwen3 | 32768 | 100+ | NO until E1 + E3 (read logits of "yes"/"no" after the fixed chat template) | MTEB-R 65.80, MMTEB-R 66.36 (reranking top-100 from Qwen3-Embedding-0.6B) |
| jina-reranker-v2 / v3 / v3.5 | jinaai/* | cc-by-nc-4.0 (v3, v3.5 read) | -- | -- | -- | -- | -- | excluded | |

### b.3 Token classification (NER) and classification / sentiment

| candidate | repo | licence | params | GGUF? | arch | languages | engine-runnable? | notes |
|---|---|---|---|---|---|---|---|---|
| bert-base-NER | dslim/bert-base-NER ; GGUF cstr/bert-base-NER-GGUF | mit | 108M | yes (community, defines the `ner.classifier.*` convention) | BertForTokenClassification | en | YES (in use) | |
| bert-base-multilingual-cased-ner-hrl | Davlan/bert-base-multilingual-cased-ner-hrl | **afl-3.0** | 177M | none seen | BertForTokenClassification (cased mBERT WordPiece) | 10 high-resource languages (not enumerated on the API) | PARTLY: the engine could run it after a conversion to the NER-head convention | AFL-3.0 is permissive-ish but not Apache/MIT: author to decide |
| **bert-base-multilingual-cased-masakhaner** | Davlan/bert-base-multilingual-cased-masakhaner | **none stated** (YAML metadata missing) | ~177M | none seen | BertForTokenClassification | Hausa, Igbo, Kinyarwanda, Luganda, Luo, Nigerian Pidgin, Swahili, Wolof, Yoruba | PARTLY (WordPiece; conversion needed) | card F1 Hausa **88.66**, Pidgin 88.96, Swahili 88.23, Wolof 66.27; types DATE/LOC/ORG/PER. Licence unclear -> cannot be adopted until clarified; dataset MasakhaNER (arXiv 2103.11811) |
| xlm-roberta-base-masakhaner | Davlan/xlm-roberta-base-masakhaner | none stated | ~278M | none seen | XLMRobertaForTokenClassification | same African set | NO: E4 | |
| GLiNER multi v2.1 | urchade/gliner_multi-v2.1 | apache-2.0 | 289M | none (library `gliner`) | DeBERTa-v3 span model (backbone not stated on the API) | multilingual zero-shot NER | NO: new arch | zero-shot arbitrary labels |
| nlptown/bert-base-multilingual-uncased-sentiment | same | mit | 167M | none seen | BertForSequenceClassification (5 stars) | en nl de fr it es | PARTLY: WordPiece ok, needs E5 (N-way head) + conversion | no Arabic, no African languages |
| lxyuan/distilbert-base-multilingual-cased-sentiments-student | same | apache-2.0 | 135M | none seen | DistilBertForSequenceClassification (3 classes) | en ar de es fr ja zh id hi it ms pt | PARTLY: DistilBERT has no token-type embeddings; needs E5 + a small variant in the backbone | the only Apache/MIT sentiment model found that tags Arabic and French |
| cardiffnlp/twitter-xlm-roberta-base-sentiment | same | not stated | -- | none | XLM-R classification | multilingual | NO: E4 | licence unclear |
| papluca/xlm-roberta-base-language-detection | same | mit | 278M | none | XLM-R classification | 20 (ar bg de el en es fr hi it ja nl pl pt ru sw th tr ur vi zh) | NO: E4 + E5 | no Hausa/Zarma |
| Davlan/afrisenti-twitter-sentiment-afroxlmr-large | same | not read | -- | none | XLM-R large | AfriSenti (Hausa among 14) | NO | licence/arch not read; AfriSenti dataset repos exist under HausaNLP |
| Davlan/afro-xlmr-base | same | mit | 278M | none | XLMRobertaForMaskedLM | 19 African languages | NO: E4 | base for fine-tuning only |

Zarma (dje) has **no** classification/NER model found. Zarma resources found on HF are community fine-tunes of Gemma 3 270M/1B (Gemma terms, not Apache), a Whisper ASR, TTS, a fastText embedding (`27Group/zarma-fasttext`) and `Mamadou2727/m2m100_418M-correction-zarma`; none vetted here.

### b.4 Language identification

| candidate | repo | licence | size | arch | coverage | engine-runnable? | notes |
|---|---|---|---|---|---|---|---|
| **GlotLID v3** | cis-lmu/glotlid (`model.bin`) | `other`: card says Apache-2.0 **plus notices** | 1,608.9 MiB | fastText | 2,102 labels; table rows read: **dje_Latn (Zarma) F1 0.994 on 8,002 test sentences, hau_Latn F1 0.989, fuv_Latn 0.985**, fra_Latn 0.930, arb_Arab 0.845, ary_Arab 0.934 | NO as shipped, but fastText inference is small (hashed char n-grams, mean embedding, linear/softmax): a pure-Zig reader is a bounded task | taq/son/knc rows were beyond the part of the table I read |
| CommonLingua | PleIAs/CommonLingua | apache-2.0 | 2.35M params | byte-level hybrid (trigram hash embedding, 3 causal conv1d, 1 attention layer) | 334 labels, 61 African languages (Hausa/Zarma not named on the card), macro-F1 0.788 on CommonLID | NO (PyTorch only) but tiny | released 2026-04-27, GSMA Africa initiative; claims +11.5 F1 over GlotLID v3 on CommonLID |
| LIDstral-Arabic | mistralai/LIDstral-Arabic | apache-2.0 | not stated | fastText + MLP stacker | 51 classes: MSA, dialects, and other Arabic-script languages; Moroccan F1 88.67 vs GlotLID 71.28 | NO | text only |
| fasttext-language-identification | facebook/fasttext-language-identification | **cc-by-nc-4.0** | ~1.33 GB | fastText | 217 | -- | excluded for licence |
| xlm-roberta-base-language-detection | papluca/... | mit | 278M | XLM-R | 20 | NO (E4+E5) | too few languages |

### b.5 Translation

| candidate | repo | licence | params | size | arch | languages | engine-runnable? | notes |
|---|---|---|---|---|---|---|---|---|
| **MADLAD-400 3B-MT** | google/madlad400-3b-mt ; GGUF community only (jbochi/..., mtsdurica/madlad400-3b-mt-Q4_K_M-GGUF ...) | apache-2.0 | 2.94B | Q4_K_M/Q8 not read | T5ForConditionalGeneration (encoder-decoder) | several hundred languages incl. ar, fr, sw (full list not read) | NO: encoder-decoder (a new graph + SentencePiece) | the best licence + coverage combination; Hausa/Zarma coverage not checked on the card |
| M2M100-418M | facebook/m2m100_418M | mit | ~418M | not read | M2M100 enc-dec | 100 languages incl. **ha** | NO: enc-dec + SentencePiece | the Zarma correction fine-tune `Mamadou2727/m2m100_418M-correction-zarma` builds on it |
| Opus-MT (Marian) pairs | Helsinki-NLP/opus-mt-fr-ha, -ha-fr, -en-ha, -ha-en, -en-fr ... | apache-2.0 (fr-ha and en-fr read) | ~75M each | ~300 MB each (not read) | Marian enc-dec | per pair | NO: enc-dec + SentencePiece | one model per pair: fr-ha and ha-fr exist; no dje pair |
| NLLB-200 distilled 600M | facebook/nllb-200-distilled-600M | **cc-by-nc-4.0** | ~600M | -- | M2M100 | 200, includes hau_Latn; **no dje** (tag list checked) | excluded for licence | |
| EuroLLM-1.7B-Instruct | utter-project/EuroLLM-1.7B-Instruct | apache-2.0 | 1.66B | no GGUF seen | llama | 35 incl. ar, fr, hi | NO: SentencePiece tokenizer | translation-capable chat model |

No Apache/MIT decoder-only translation model <= 4B was found; the Feriji French-Zarma paper (arXiv 2406.05888) reports BLEU 30.06 for its best fine-tuned LLM, but I did not confirm the weights are published.

### b.6 Summarisation, grammar, spelling

| candidate | repo | licence | params | arch | engine-runnable? | notes |
|---|---|---|---|---|---|---|
| bart-large-cnn | facebook/bart-large-cnn | mit | 406M | BART enc-dec | NO | English news summariser |
| flan-t5-base / large | google/flan-t5-base, -large (GGUF community: Felladrin/gguf-flan-t5-base) | apache-2.0 | 248M / 783M | T5 enc-dec | NO | en fr ro de; instruction-tuned, can summarise and correct |
| mT5_multilingual_XLSum | csebuetnlp/mT5_multilingual_XLSum | **cc-by-nc-sa-4.0** | -- | mT5 | excluded | |
| spelling-correction-english-base | oliverguhr/spelling-correction-english-base | mit | 139M | BART | NO | English only |
| flan-t5-large-grammar-synthesis | pszemraj/flan-t5-large-grammar-synthesis | metadata lists BOTH cc-by-nc-sa-4.0 and apache-2.0 | 783M | T5 | NO | conflicting licence tags: treat as non-commercial until resolved |
| (an LLM from a.1) | -- | -- | -- | -- | -- | for summarise / GEC, a 1.7B-4B instruct model with a prompt is the practical route; no dedicated Apache/MIT multilingual GEC model was found |

---

## Algorithmic FLOOR (what Softanza already has, read from the tree)

Paths relative to `D:\GitHub\_wti\libraries\stzlib\`.

| domain | floor | where | plausible quality (judged from the code and its own comments; not benchmarked here) |
|---|---|---|---|
| chat | `stzConversation` (goal-driven question/answer protocol with governed admission, `Reply`, `NextQuestion`, `Options`); `SetFluency(:plain|:neural)` falls back to the template phrasing; `stzTutor`; `stzNNL`, `stzNaturalLangData` (en/fr/ar packs mapping phrases to semantic IDs); `stzQuestion` | `base/conversation/stzConversation.ring`, `base/education/stzTutor.ring`, `base/natural/` | A scripted, slot-filling dialogue engine. It is not open-domain chat. "No floor" for free conversation. |
| summarise | extractive: TextRank over sentences (`str_summarize`, word-overlap graph, emitted in reading order) + RAKE key phrases + TextRank keywords; embedding-TextRank when a BERT model is loaded; `SummarizedAbstractively()` calls the LLM and degrades to the extractive one | `engine/src/string/textrank.zig`, `textutil.zig`; `base/linguistic/stzText.ring` (`SummarySentences`, `Summary`, `KeyPhrases`, `RankedKeywords`) | Sound classical extractive baseline, language-agnostic in structure but its stopword list is English only (`data/stopwords_en.txt`). |
| classify | zero-shot `Classify(labels)` (embedding cosine if a model is loaded, else lexical); `stzNaiveBayes` (multinomial, Laplace, engine-resident, UAX#29 tokens), `stzKnn`, `stzLogisticRegression`, `stzDecisionTree`, TF-IDF on `stzCorpus`; `stzRequestClassifier` (3-tier router: rules, lexical, model) | `base/linguistic/stzText.ring`; `base/learning/*.ring`; `base/cluster/stzRequestClassifier.ring`; `engine/src/ngram.zig`, `bayes.zig` | Naive Bayes trained on a few dozen labelled examples is a real floor; zero-shot without a model is weak lexical overlap. No BM25 anywhere (grepped `bm25`: no hit). |
| sentiment | VADER, ~7,500-term lexicon compiled in, five heuristics | `engine/src/string/sentiment.zig`; `stzText.Sentiment()/SentimentScore()` | Good on English social text; **English only** by its own header. French, Arabic, Hausa: no floor beyond training `stzNaiveBayes` yourself. |
| NER | POS (averaged perceptron, NLTK weights) + gazetteers (first names, places, orgs) + context rules; upgrades to BERT NER head if loaded | `engine/src/string/ner.zig`, `pos.zig`; `stzText.NamedEntities()` | English-only classical NER; PERSON/ORG/LOC. French/Arabic/Hausa: no floor (POS tagger and gazetteers are English). |
| language ID | script test (Arabic) + 6 marker-word lists (en fr es de it pt, ~20 words each) | `engine/src/string/textutil.zig` `str_detect_language`; `stzString.DetectScript` in `base/string/stzStringLocale.ring` | The code itself calls it a heuristic, "not an n-gram language model". Cannot output Hausa, Zarma, Fula; any non-Arabic-script text with no marker hit is "unknown". |
| morphology | Snowball stemmers (25 languages), lemma tables en/fr/ar (Wiktionary-derived, ODbL), WordNet synonyms/hypernyms, phonetic codes | `engine/src/string/stem.zig`, `lemma.zig`, `wordnet.zig`, `phonetics.zig` | Good rule/table floor for fr/ar normalisation; useful as features for Naive Bayes. |
| translation | **no floor** (the `Translate` hits in `base/geo/` are geometric translation) | -- | -- |
| spell / grammar | Levenshtein, Hamming, Jaro-Winkler, Jaccard, edit-distance clustering, phonetic codes (primitives only); `stzObject`/`stzSemanticResolver` do fuzzy matching of method names | `engine/src/string/fuzzy.zig`, `phonetics.zig` | Primitives for a "did you mean" over a word list; **no spell checker, no dictionary, no grammar floor**. |
| embeddings / retrieval | TF-IDF per document (`stzCorpus.TfIdfOf/TopTermsOf`), n-gram LM, kNN, ANN, `stzSemanticIndex` (needs a model) | `base/linguistic/stzCorpus.ring`, `engine/src/ngram.zig`, `ann.zig`, `knn.zig`, `base/neural/stzSemanticIndex.ring` | TF-IDF cosine is the lexical floor for any retrieval/rerank test. |
| rerank | none dedicated; TF-IDF cosine / `MostSimilarSentenceTo` | as above | use TF-IDF cosine as the floor. |
| extraction / structured output | `stzOutputSchema` (declare, parse, validate, refuse), `stzLLMFunction` (typed call with schema and retries), GBNF schema compiler + sampler-side stack machine (a violating token is unemittable), regex/pattern engine | `base/neural/stzOutputSchema.ring`, `stzLLMFunction.ring`, `SOFTANZA_STRUCTURED_OUTPUT.md` (C9), `engine/src/schema_gbnf.zig`, `gbnf_machine.zig` | Structure is already guaranteed (spec: "kills malformedness, not falsehood"); the open question is correctness of values, which the golden task below measures. |

---

## Golden tasks (one per domain; not built)

All checkers are deterministic code (no LLM judge). Each is scored for the model AND the floor on the same items; "model beats floor" = model score exceeds floor by more than the item-level noise (use a paired sign test or just require >= +3 items of 15).

1. **Structured extraction** (15 items). Item: `{text, schema, gold}`; text is a short invoice / message / ticket in en or fr; schema is a `stzOutputSchema` with 3-5 typed fields; gold is the exact JSON. Checker: parse; per-field exact match after type normalisation (numbers numerically, dates ISO, strings case-folded and trimmed); score = fields correct / fields total; also record schema-valid rate. Floor: regex/pattern extraction written by the test author for each item class.
2. **Summarisation** (12 items). Item: a 120-250 word article with a hand-listed set of 4-6 "must-keep facts" (named entities, numbers, dates) and a length cap. Checker: recall of facts by normalised substring match; precision guard: every number and capitalised entity in the output must occur in the source (catches hallucination); length <= cap. Floor: `SummarySentences(2)` / `Summary(2)`.
3. **Classification / intent** (20 items). Item: `{text, labels[], gold}` in en/fr/ar (7/7/6), 4-5 labels each, written to avoid label words appearing in the text. Checker: exact label match; report accuracy per language. Floors: `ClassifiedAs(labels)` (zero-shot) and `stzNaiveBayes` trained on 5 examples per label.
4. **Sentiment** (20 items). Item: `{text, gold in pos|neg|neu}`; en 6, fr 6, ar 4, ha 4 (ha items taken from the author-labelled sentences, not from a dataset with an unchecked licence). Checker: accuracy and macro-F1 per language. Floor: VADER (expected to collapse outside English), Naive Bayes trained on the other items by leave-one-out.
5. **NER** (15 items). Item: `{sentence, gold spans [(text, type)]}` with types PER/ORG/LOC, en 5, fr 5, ha 5 (Masakhane-style). Checker: span-level exact-match precision/recall/F1 on the set of (surface, type) pairs; partial credit not given. Floor: `NamedEntities()`.
6. **Language ID** (20 items). Item: `{text 15-40 words, gold ISO-639-3 code}` covering eng, fra, arb, ary, hau, dje, fuv, ita, spa, swh with 2 each; 3 of them mixed-script or code-switched with a declared dominant language. Checker: exact code match (a fixed table maps the floor's names "english"... to codes); "unknown" counts wrong. Floor: `Language()` (6 languages only).
7. **Translation** (15 items). Item: `{src_lang, tgt_lang, source, reference, must_keep[]}` with directions en->fr, fr->en, fr->ha, ha->fr, fr->dje (the last only if a model claims it); sentences carry numbers/names in `must_keep`. Checker: chrF (character n-gram F-score, implementable in 30 lines) against the reference, plus a hard gate that every `must_keep` token survives. Floor: none exists; the floor is "copy the source" (scores the named-entity/number carry-over only). Optionally compare with a bilingual lexicon floor.
8. **Embedding** (15 triplets + one 20-document retrieval set). Item: `(anchor, positive, negative)` including cross-language pairs (fr anchor / en positive / en lexical-overlap negative) and Hausa pairs. Checker: fraction with `cos(a,p) > cos(a,n)`; retrieval recall@1 over the 20-document set. Floor: TF-IDF cosine (`stzCorpus`) and the already-running MiniLM.
9. **Rerank** (15 queries x 5 candidates, 1 relevant, 2 lexical-overlap traps). Checker: top-1 accuracy and MRR from the score order. Floor: TF-IDF cosine; second baseline jina-reranker-v1-turbo-en.
10. **Spelling / grammar** (20 items). Item: `{noisy, gold}`, 15 with one injected typo or agreement error (en 10, fr 5), 5 already-correct controls. Checker: exact match to gold after whitespace normalisation; controls must come back unchanged (false-edit rate reported). Floor: identity (no floor exists); optional Levenshtein-to-wordlist baseline if a word list is added.
11. **Chat** (15 scripted dialogues, 3 turns each). Item: a context paragraph and a script of user turns whose answers are in the context. Checker: each model reply must contain the required slot value (normalised substring) and none of a forbidden list (e.g. a value from a distractor paragraph); a dialogue passes only if all three turns pass. Floor: `stzConversation` frames (`Reply` with `:plain` fluency) driven by the same slot data.

---

## Verified vs not verified

**Verified on a live page (HF API / tree / card, 2026-10-21):** all `license`, `architectures`, `gguf.architecture`, `gguf.context_length`, `gguf.total`, parameter counts, creation dates and the byte sizes in the tables marked as GiB/MiB, for: Qwen3-0.6B/1.7B/4B GGUF repos, Qwen3-4B-Instruct-2507 (+ unsloth GGUF), Qwen3-4B-Thinking-2507, Qwen3.5-0.8B/2B/4B (unsloth GGUF sizes), Qwen2.5-3B licence, DeepSeek-R1-Distill-Qwen-1.5B (both repos), SmolLM2-360M/1.7B GGUF, SmolLM3 (ggml-org GGUF), Llama-3.2 (bartowski), Gemma-3-1b, Gemma-4-E2B (+ GGUF sizes), Phi-4-mini (+ bartowski sizes), Granite 4.0 350m/1b/micro GGUF and sizes, Granite 4.1-3b, Granite 4.2-3b GGUF and sizes, Ministral-3-3B (+ GGUF sizes), LFM2/LFM2.5 licence, Jais-3 0.9B/3.7B GGUF, Pleias-RAG, Qwen3-Embedding-0.6B GGUF, bge-m3 GGUF, multilingual-e5-small GGUF, LaBSE GGUF, bge-reranker-v2-m3 GGUF, GlotLID file sizes and rows for dje/hau/fra/ara/ary/fuv, CommonLingua, LIDstral-Arabic, NLLB/M2M100/MADLAD/Opus-MT licences, bart-large-cnn, flan-t5, Davlan NER, nlptown, lxyuan, papluca, GLiNER, jina v3/v5/reranker licences, EmbeddingGemma-2, bitnet-embedding-270m, pplx-embed-v2-late-0.6b. The Qwen3-Embedding / Qwen3-Reranker / Granite-4.1/4.2 / Masakhaner cards were read for the figures quoted from them.

**Engine claims:** read from source in `D:\GitHub\_wti` (branch `intelligence/model-flow`, uncommitted changes present), not executed.

**NOT verified (or only from a secondary source):**
- That the engine mis-handles Qwen3 without QK-norm: inferred from reading the code, never run. A 5-minute parity probe would settle it.
- `tokenizer.ggml.model` / `tokenizer.ggml.pre` of every GGUF above (the HF API does not expose them). Statements that bge-m3 / e5 / bge-reranker GGUFs carry a unigram tokenizer, that Granite and Phi-4-mini use a GPT-2-type BPE, that the Pleias tokenizer fits, come from background knowledge of llama.cpp conversions.
- Granite scalar multipliers and the claim that the 4.0-1b GGUF is attention-only (HF config says `granitemoehybrid`; the GGUF says `granite`; I could not read the config fields).
- Q8_0 / Q4_K_M sizes for: Granite-4.1-3B (estimated from the identical 4.0-micro), Qwen3-4B-Thinking-2507 (estimated), bge-m3 K-quants, multilingual-e5-base/large, nomic, MADLAD GGUFs, Qwen3-Reranker GGUFs, Opus-MT, GLiNER, NER/sentiment models. Qwen2.5-1.5B and Llama-3.2 sizes are the fetch tool's rounded figures (unit unconfirmed).
- The vendor repo `Qwen/Qwen3-Reranker-0.6B-GGUF` and `ChristianAzinn/multilingual-e5-small-gguf` returned HTTP 401 via the fetch tool: existence unconfirmed (community alternatives listed instead).
- Language lists of bge-m3, Qwen3 (119), MADLAD (does it include Hausa/Zarma?), Opus-MT coverage, Davlan hrl NER languages, Granite 4.0 language list (taken from the 4.1/4.2 cards).
- Licence of `ms-marco-MiniLM-L6-v2`, `bge-reranker-base/large`, `afrisenti-twitter-sentiment-afroxlmr-large`, Masakhaner models (none stated), `Tiny Aya` (CC-BY-NC per a secondary article).
- Release-tracker data (nocode.mba, turingpost) was used only to find names; every model that appears in the tables was then checked on huggingface.co. Items I could not check on HF and therefore did not list as candidates: Liquid `d1-3B`, `d1-omni-600M`, NVIDIA `Bolt E4B`, Kolibri, Cloudflare Clef, `kettei`.
- No benchmark of any model was run; all quality statements about models are the vendor cards' own numbers or my reading of code.
