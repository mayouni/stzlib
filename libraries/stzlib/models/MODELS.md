# The models Softanza holds (`libraries/stzlib/models/`), as of 2026-10-21

`*.gguf` is ignored by git, so these are local assets and this file is their record: what each is, where it came from, its licence, its size and its **sha256** (verified after download and against the publisher's listing where one exists). The engine holds **one** model at a time; a flow that needs an embedding model and a generative one loads them in turn (`StzEnsureModelResident`, a measured load-swap: 0.2 to 1.3 s for the models below).

| file | what | size (bytes) | sha256 | licence | source |
|---|---|---|---|---|---|
| `all-MiniLM-L6-v2.Q8_0.gguf` | sentence embeddings (BERT, 384-d) | 25,008,064 | `e5ec722e8c82dc4ffaf965175ca472f5da3f97b695590b5b0780bdbfa29bcaf3` | Apache-2.0 | in the tree before 2026-10 |
| `jina-reranker-v1-turbo-en-Q8_0.gguf` | cross-encoder reranker (English) | 41,719,968 | `6633027dd42a9490313504ce698dcd8bbd44f8694e58ab555e2d06d8535f4f86` | Apache-2.0 | in the tree before 2026-10 |
| `smollm2-135m-instruct-q8_0.gguf` | chat, 135M (arch llama) | 144,811,360 | `5a1395716f7913741cc51d98581b9b1228d80987a9f7d3664106742eb06bba83` | Apache-2.0 | in the tree before 2026-10 |
| `qwen2.5-coder-0.5b-instruct-q8_0.gguf` | code and chat, 0.5B (arch qwen2) | 675,710,848 | `e1a77721fa97d412f121878223eec81fb4ae6f271e18f922d746711f67b344d1` | Apache-2.0 | `huggingface.co/Qwen/Qwen2.5-Coder-0.5B-Instruct-GGUF` (downloaded 2026-10-20) |
| `qwen2.5-coder-1.5b-instruct-q8_0.gguf` | code and chat, 1.5B (arch qwen2) — **the first model that computes rather than hard-codes in the K4 test** | 1,894,532,160 | `507de59046601282ba768a9789900e6ccf60ed93ddf346730b7c68eb0715bc47` | Apache-2.0 | `huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF` (downloaded 2026-10-20) |
| `Qwen3-0.6B-Q8_0.gguf` | chat, 0.6B (arch **qwen3**) | 639,446,688 | `9465e63a22add5354d9bb4b99e90117043c7124007664907259bd16d043bb031` | Apache-2.0 | `huggingface.co/Qwen/Qwen3-0.6B-GGUF` (2026-10-21) |
| `Qwen3-0.6B-Q4_K_M.gguf` | the same, k-quantised — **proves the engine reads k-quants** | 396,705,472 | `ac2d97712095a558e31573f62f466a3f9d93990898b0ec79d7c974c1780d524a` | Apache-2.0 | `huggingface.co/unsloth/Qwen3-0.6B-GGUF` (2026-10-21) |
| `granite-4.0-1b-Q8_0.gguf` | chat, 1B (arch **granite**, dense) — **the first model to beat a floor on a generative task** (extraction, read by probability: 0.72 vs 0.56) | 1,737,791,232 | `0660c20c3d3d3672b90f0468f62dc128a82a6e3ee2ec05d310d242969be06140` | Apache-2.0 | `huggingface.co/ibm-granite/granite-4.0-1b-GGUF` (2026-10-21; sha256 verified against the listing) |
| `granite-4.0-350m-Q8_0.gguf` | chat, 350M (arch **granite**, dense; 12 languages incl. French and Arabic) | 378,138,016 | `9595dafb4ed15aa02512c8ea26188744192a6f09530eae0a2747bd3ada96cd36` | Apache-2.0 | `huggingface.co/ibm-granite/granite-4.0-350m-GGUF` (2026-10-21) |
| `granite-4.2-3b-Q4_K_M.gguf` | generator (Granite dense, 3B) | 2,244,011,552 | `e0406663965846ae22a403456eb826ccce5f450840491f71952f18a7cb78e7d5` | Apache-2.0 | IBM Granite 4.2, size and digest match the publisher; dense; speaks ChatML with a `<think></think>` thinking-off block, NOT Granite 4.0's role markers. Measured 2026-10-22: extraction 0.69 (floor 0.56), classification 0.67 (floor 0.69), brief 0.58 (floor 0.69) |

## What was needed for each to run (engine commits, 2026-10-21)

- **The 1.5B** could not load before `2f5dd6c33`: the forward pass's memory pool was a formula a few hundred KB short; it is now measured from the graph.
- **A long prompt** is no longer cut to its last 512 tokens (`9c7514fc4`): it is prefilled whole in chunks and bounded by the model's context; one that does not fit is refused with a sentence.
- **Qwen3** needed per-head q/k RMSNorm and a head width that is not hidden/heads (`98d5eb732`); it aborted the process before.
- **Granite** needed four scalars (`703cfc051`); a hybrid or mixture-of-experts Granite file is refused, not crashed on.
- `StzGenerateXT` gained `:RepeatPenalty`, `:StopOnRepeat`, `:EndBias` (`13ea45735`).

## How to use them

- **Load explicitly**: `StzAutoLoadNeuralModel()` takes the first `*.gguf` in directory order — the embedding model on Windows. To generate with one: `StzNeuralModelQ("<path>/granite-4.0-350m-Q8_0.gguf")`, then `StzGenerateXT(...)`; or let the model-flow registry (`base/faculty/`) make it resident when a flow needs it.
- **Quality is MEASURED, not assumed.** `base/test/faculty/results/measurements.zmdl.txt` records each model's score against its hand-written floor on each faculty's golden set. On the support-desk sets (2026-10-21): the embedding model beats its floor on retrieval (1.00 against 0.50); **no model under 1B beats its floor on extraction, brief or classification** (best: 0.39 against 0.56; 0.56 against 0.69; 0.64 against 0.69 — the last two read by probability, `StzOptionProbabilities`, which beat generation for every model that works). **At 1B it changes**: Granite-4.0-1b read by probability scores **0.72 against the extraction floor's 0.56** and the registry now chooses it there; it ties the classification floor (0.67 against 0.69) and loses on brief (0.53 against 0.69); the Jina reranker loses to its floor (0.33 against 0.42). The registry therefore selects only MiniLM, and the floors elsewhere.
- **Speed** was measured with the CPU firmware-throttled to 42–57 % of nominal: not a figure to quote.

## Document tools (not model files)

- **Docling 2.141.0** is installed in an isolated virtual environment outside the tree (`D:\GitHub\_wt_dl\docling-venv`), for the baselines of `SOFTANZA_DOCUMENT_INTELLIGENCE_MEMO.md`. It is a measuring tool, not a dependency of the library; its own models download from Hugging Face on first use.
