# B4 -- Datalab open models (incl. Indra) for the Softanza small-model survey

Read live 2026-10-21 (GitHub `main`/`master` heads and Hugging Face `main`; no weights downloaded; only READMEs, LICENSE files, config.json, file-tree listings and the Indra Python source were fetched, into the session scratchpad). Source for every claim is a URL below; "UNVERIFIED" marks anything not read from a primary source.

## 0. Executive summary

1. **Indra OCR is a CPU document-OCR pipeline, not a language model or VLM.** It is a bundle of small ONNX networks (line detector, CTC line recognisers, script classifier, orientation net, reading-order net, optional math decoder) plus n-gram language models and a large amount of Python post-processing. 1.25M parameters in the Latin recogniser, 7.3M in all default models, 76 MB downloaded (102 MB repo). Created 2026-10-13. https://github.com/datalab-to/indra , https://huggingface.co/datalab-to/indra-ocr
2. **Weights licence: not permissive. Code is Apache-2.0; every Datalab *weight* file I checked (the 2026 ones) is under a modified AI Pubs OpenRAIL-M (v0.1, "Modified") with a per-model revenue/funding cap and a no-compete clause.** Indra: $20,000,000. Surya OCR 2, Surya layout2, lift, surya-parsebench-rl: $5,000,000. Chandra / Chandra OCR 2: $2,000,000. The older Surya v1 / Texify weights are **CC-BY-NC-SA-4.0** (non-commercial). A free, open-source library that bundles these weights does **not** meet the Apache/MIT-preferred bar: see section 2.
3. **Only Surya OCR 2 (0.65B) fits the <= ~3 GB budget and has a GGUF + llama.cpp path**; it is a Qwen3.5-architecture VLM (Gated-DeltaNet hybrid + 12-layer ViT). The vendored ggml already contains `GGML_OP_GATED_DELTA_NET`, `SSM_CONV`, `rope_multi`, `conv_2d`, so the op set is probably there, but the engine has no vision tower, no image-token splice, no recurrent-state cache, no second model slot, and its arch whitelist is llama/qwen2/qwen3/smollm. Chandra OCR 2 (5.3B), Chandra 1 (8.8B) and lift (9.7B) are over budget.
4. **Recommendation:** do **not** put any Datalab weights on Softanza's default shipped path. If a Datalab model is wanted at all, make Indra an *optional, user-fetched, clearly labelled "restricted-licence" adapter* (not redistributed in the repo), and build the permissive document-intelligence baseline first from Apache/MIT parts (text-layer extraction + Tesseract/other permissive OCR as the floor; Granite-Docling-258M as the first VLM candidate). Use the golden tasks in section 6 to decide whether any restricted model earns its place. Not legal advice; a lawyer should read Attachment A before any redistribution.

## 1. Everything public under datalab-to

### 1.1 GitHub: 14 public repositories (https://github.com/datalab-to ; API listing https://api.github.com/orgs/datalab-to/repos?per_page=100, read 2026-10-21)

| repo | what | code licence | stars | last push | relevance |
|---|---|---|---|---|---|
| **indra** | Fast CPU OCR: line detection, CTC recognition, reading order, markdown (ONNX Runtime) | Apache-2.0 | 860 | 2026-10-20 | **the asked-for model**; created 2026-10-13 |
| **surya** | OCR, layout, reading order, table recognition, 90+ languages. v2 = single VLM served by vLLM or llama.cpp, plus a torch text-line detector | Apache-2.0 | 21,516 | 2026-09-11 | core |
| **marker** | PDF to markdown/JSON pipeline built on the surya VLM + small CPU models; optional `--use_llm` hybrid | Apache-2.0 | 40,569 | 2026-10-19 | pipeline, not a model |
| **chandra** | Datalab's highest-accuracy OCR VLM (handwriting, forms, tables, math) | Apache-2.0 (code) | 12,522 | 2026-06-26 | too big (5.3B) |
| **lift** | Schema-constrained structured extraction from PDFs/images (JSON out) | Apache-2.0 (code) | 1,196 | 2026-10-05 | 9.7B, too big |
| **pdftext** | Text-layer extraction on pypdfium2 (PyMuPDF replacement, no AGPL) | Apache-2.0 | 732 | 2026-07-08 | usable idea/floor; code only |
| **omni_parse_bench** | Datalab's parsing benchmark runner: 16,288 pass/fail tests on 2,937 pages; tests tagged with ISO 639-3 language (`fra`, ...) and script | Apache-2.0 code; data licence per source | 24 | 2026-10-21 | useful test design |
| **omni_extract_bench** | Structured-extraction benchmark | Apache-2.0 | 36 | 2026-10-21 | |
| **sdk** | Client SDK for Datalab's hosted API | MIT | 12 | 2026-10-19 | irrelevant (hosted) |
| **datalab-on-prem** | Scripts for Datalab's self-service on-prem container | none stated | 8 | 2026-07-14 | commercial |
| **oss_container** | "Evaluation only" marker inference container | none stated | 2 | 2025-10-02 | |
| **inference-mirror** | Older marker inference service container | none stated | 4 | 2025-08-13 | |
| **pykatex** | KaTeX validator via QuickJS (used to validate LaTeX output) | none stated | 4 | 2026-02-05 | possible checker idea |
| **tutorials** | Sample code from blog posts | none stated | 0 | 2026-10-19 | |

**Texify** is not in the org: the Hugging Face weights `datalab-to/texify` (169,044,120 params, F16, 2025-01-26) point at `VikParuchuri/texify`, which the GitHub API shows as **GPL-3.0, archived** (last push 2025-01-29). Weights are CC-BY-NC-SA-4.0. Superseded by Surya 2's inline `<math>` output. https://huggingface.co/datalab-to/texify , https://api.github.com/repos/VikParuchuri/texify

### 1.2 Hugging Face: 17 models, 11 datasets, 1 Space (https://huggingface.co/datalab-to ; API https://huggingface.co/api/models?author=datalab-to&limit=100)

| HF id | task / format | params; size | weights licence tag | notes |
|---|---|---|---|---|
| datalab-to/**indra-ocr** | OCR, ONNX | 1.25M (Latin rec, safetensors "for count only"); repo 102 MB; default download 76 MB | openrail (modified, $20M) | 2026-10-10; Space `datalab-to/indra-ocr` |
| datalab-to/**surya-ocr-2** | VLM, safetensors BF16 | 0.65B; 1,372,368,672 B | openrail ($5M) | 2026-05-14; 1.5M downloads |
| datalab-to/**surya-ocr-2-gguf** | same, GGUF | `surya-2.gguf` 1,266,400,864 B + `surya-2-mmproj.gguf` 204,986,688 B (about 1.47 GB total; quantisation not stated, size implies 16-bit) | openrail ($5M) | tags: gguf, qwen3_5; 641k downloads |
| datalab-to/**surya-parsebench-rl** | research RL checkpoint of surya-ocr-2 | 0.67B (665,701,440) | openrail ($5M) | "not a product model"; 70 RL steps |
| datalab-to/**surya_layout2** | fast layout detector, RF-DETR | `rfdetr_layout.pth` 134,915,547 B | openrail ($5M) | CPU or GPU; needs `surya` torch package |
| datalab-to/**chandra-ocr-2** | VLM | 5.30B (5,295,564,288); 10.59 GB safetensors | openrail ($2M) | 1.47M downloads |
| datalab-to/**chandra** | VLM (v1) | 8.77B; 17.5 GB | openrail ($2M) | Qwen3-VL arch |
| datalab-to/**lift** | structured-extraction VLM | 9.65B | openrail ($5M) | Qwen3.5 arch, hidden 4096 |
| datalab-to/texify, surya_layout0, surya_layout, surya_tablerec, line_detector0, inline_math_det0, ocr_error_detection, foundation-ocr-test, surya-alpha | legacy Surya v1 components | texify 169M; line_detector0/inline_math_det0 = EfficientViT; others vision-encoder-decoder | **cc-by-nc-sa-4.0** | non-commercial; ignore |

Datasets: omni_parse_bench (443k tests/rows), omni_extract_bench, marker/fintabnet/inline-math benches (2025). Third-party conversions exist (not Datalab's, unaudited): ONNX, MLX, NVFP4, many GGUF quants of chandra-ocr-2, `cstr/surya-det-GGUF`, `Prince-1/Surya-Ocr-2-Onnx`. https://huggingface.co/api/models?filter=base_model:quantized:datalab-to/surya-ocr-2 . They inherit the Datalab licence.

## 2. The weights licence, verified at file level

Primary text: the `LICENSE` file in each HF repo (all "Version 0.1, March 2, 2023 (Modified)", a modified "AI Pubs Open Rail-M"). I diffed surya-ocr-2 against chandra-ocr-2: **the only difference is the dollar figure**. Files:
https://huggingface.co/datalab-to/indra-ocr/raw/main/LICENSE ,
https://huggingface.co/datalab-to/surya-ocr-2/raw/main/LICENSE ,
https://huggingface.co/datalab-to/chandra-ocr-2/raw/main/LICENSE (and the lift, layout2, parsebench-rl, chandra, surya-ocr-2-gguf copies, same wording).

Attachment A, section 2 "Commercial" (verbatim, with the figure varying by repo):
- (a) "for any purpose if You (your employer, or the entity you are affiliated with) generated more than [X] US Dollars in gross revenue in the prior year, except where Your Use is limited to personal use or research purposes;"
- (b) "... has raised more than [X] US dollars in total equity or debt funding from any source, except where Your Use is limited to personal use or research purposes; or"
- (c) "... provides or otherwise makes available any product or service that competes with any product or service offered by or made available by Licensor or any of its affiliates."
- Closing line: "Commercial and broader use licenses may be available from Licensor at ... https://www.datalab.to/"

| weights | X (revenue AND funding) |
|---|---|
| **indra-ocr** | **$20,000,000** |
| surya-ocr-2, surya-ocr-2-gguf, surya_layout2, surya-parsebench-rl, lift | $5,000,000 |
| chandra, chandra-ocr-2 | $2,000,000 |
| texify, surya v1 parts, surya-alpha, ... | CC-BY-NC-SA-4.0 (non-commercial) |

The thresholds are tested on the **user** ("You (your employer, or the entity you are affiliated with)"), not on the distributor. Other terms that matter (same LICENSE file):
- Section 4(a): anyone who distributes the model "MUST" include the Attachment A use restrictions "as an enforceable provision ... in any type of legal agreement" and notify later users; 4(b) pass a copy of the licence; 4(c) mark modified files. Section 5: "You shall require all of Your users ... to comply."
- Section 9: Licensor "reserves the right to restrict (remotely or otherwise) usage ... update the Model through electronic means, or cause modification to the Output."
- Section 6: Licensor claims no rights in Output.
- "Datalab API" is **not defined** in the LICENSE; clause 2(c) speaks of any product/service that "competes with any product or service" of Datalab (OCR/doc-parsing is exactly Datalab's business). The READMEs paraphrase it as "cannot be used competitively with our API".
- The READMEs' own summary matches: Indra "free for research, personal use, and startups under $20M funding/revenue, cannot be used competitively with our API"; Surya "$5M"; Chandra "$2M".

**Verdict for "a free-to-ship open-source library embedding them":**
- Redistribution is *allowed* (copyright grant is royalty-free, sublicensable), but only with Attachment A flowing down to every user. The embedding library therefore stops being "Apache/MIT all the way down": a downstream company above the cap (for Indra, > $20M revenue or > $20M raised, commercial use) is barred, and so is any user whose product competes with Datalab's. That is a field-of-use restriction, so it fails an open-source/permissive criterion and fails the survey's "Apache-2.0/MIT preferred" bar. Softanza as distributor must itself be under the cap at every moment it distributes.
- Clause 2(c) is the sharper risk for Softanza: a library whose pitch includes document OCR/parsing arguably "makes available a product that competes" with Datalab's hosted OCR. Nothing defines the boundary. Needs a lawyer or a written commercial grant from Datalab.
- Indra's $20M cap is 4x Surya's and 10x Chandra's, so it is the most permissive of the family but still capped.
- The code licences (Apache-2.0) cover the Python only; Apache code in `indra` does not relicense the weights.
- UNVERIFIED: whether Chandra/Surya/lift weights are derived from Qwen3.5/Qwen3-VL weights (Chandra's README credits Qwen 3.5 / Qwen 3 VL; Surya 2 has a custom 65,425-token vocabulary, so it may be trained from scratch with the Qwen3.5 *architecture*). If derived, the base model's own licence also applies; I did not read it.

## 3. Indra OCR in detail

Sources: https://github.com/datalab-to/indra (README, CHANGELOG, `indra_ocr/*.py`, `pyproject.toml` v1.1.2), https://huggingface.co/datalab-to/indra-ocr (file tree, config.json).

**What it does.** PDFs/images to markdown, text or JSON with boxes: line detection, script routing, CTC line recognition, reading order, layout labels (heading, list, table, caption, footnote, page header), orientation fix (quarter turns, tilt up to 45 degrees), light-on-dark text, handwriting (weak), optional `--math` (inline LaTeX), and **reads the text layer of digital PDFs and OCRs only what is missing** (it checks the layer against the line images: detects Chrome visual-order Arabic layers and legacy-font Hindi layers and falls back to OCR). Named for the god Indra. Hosted answer for hard cases is Datalab's Chandra.

**Files (HF tree, sizes verified):** det.onnx 390 kB; rec.onnx 5.04 MB (Latin, Cyrillic, Greek, Latin handwriting); rec_cjk.onnx 10.2 MB; rec_rtl.onnx 4.81 MB (Arabic, Persian, Urdu, Pashto, Kurdish, Hebrew); rec_world.onnx 5.63 MB (Indic, Thai, Lao, Khmer, Myanmar, Sinhala, Georgian, Armenian, Ethiopic); script.onnx 192 kB; orient.onnx 372 kB; order.onnx 2.97 MB; n-gram LMs lm.npz 15.7 MB, lm_cjk.npz 19 MB, lm_world.npz 11.6 MB; math (opt-in): mathcls 191 kB, math_enc 9.89 MB, math_dec_init 1.36 MB, math_dec_step 8.43 MB; meta.json 212 kB (vocabularies). Default download 76 MB = 30 MB networks + 46 MB LMs. `model.safetensors` (5.01 MB) holds the float weights of rec.onnx only, "for the Hub parameter count; the package does not use it" (config.json) -- **so there is no usable safetensors checkpoint of the full system; the .onnx files are the distribution.**

**Architecture.** Not disclosed in README or card. What the source shows (pipeline.py, rec_preproc.py, lm.py, CHANGELOG): line crops resized to height 32, width padded to multiples of 8 (timestep stride 8); recognisers take `{x, widths}` and emit greedy argmax / max-prob / lengths in-graph (CTC); a CTC prefix beam search with a **token n-gram backoff LM** (`lm.npz`, plain arrays, order and 11 bits per token) re-reads lines whose confidence is under a gate; detector `det.onnx` takes `x` [1,1,H,W] (heat-map style, post-processed in `det_post.py`, `line_mask.py`); math = encoder + attention decoder with cached K/V, one token per step; optional `mask.onnx` (CenterMask) and `rec.int8.onnx` are supported by the code but not shipped in the HF tree. Whether the nets are CNN, CNN+BiLSTM or small transformers: **UNVERIFIED** (I did not download the .onnx to inspect operators).

**Training data.** Not stated (README and card). CHANGELOG 1.1.0 says line detector and Latin recogniser were trained "on real handwritten and filled-form pages", the orientation model on "real turned scans"; `rec_preproc.py` mentions synthetic and real labels. Source, licences and size: UNVERIFIED/undisclosed.

**Languages.** OCR measured on 95 languages (held-out printed pages): 83 with character F1 >= 0.90, 67 >= 0.95. Latin recogniser: about 50 languages. **French: no French-specific number; Latin script group = OmniParseBench Latin 61.6 over 9,406 tests; README says French is *not* affected by the diacritic-confusion failure (Czech, Turkish, Icelandic, ... are).** **Arabic: OmniParseBench 69.2 over only 13 tests ("one test moves a score 2-8 points")**; Arabic lines "come out in logical order"; Arabic text-layer retention >= 98%. Unsupported for OCR: Syriac, Tibetan, Mongolian, Santali, Meitei; written Cantonese characters.

**Benchmarks (all Datalab's own runs; third-party replication UNVERIFIED).** OmniParseBench (Datalab's benchmark, 2,937 pages, x86 4 vCPU): Indra auto 66.7 (text 46.7, tables 61.1, layout 92.2, median 212 ms/page); `--math` 71.4 (text 62.7, 357 ms); PaddleOCR PP-StructureV3 58.4 (40,958 ms/page, 19 pages dropped after a stalled shard); PP-OCR text models text 35.8; Tesseract 5 text 19.3 (5,496 ms). Indra's own accuracy comes "from the benchmark's own Indra OCR adapter and scorer"; other engines are Datalab's runs. Handwriting 25.2, degraded scans 29.5, math tests 14.0 (55.8 with `--math`). olmOCR-bench subsets vs Tesseract 4: headers/footers 91.2 vs 35.5, tables 60.5 vs 1.0, multi-column 70.0 vs 70.4, old scans 20.0 vs 18.4. OmniDocBench v1.5 (OCR only, 1,651 pages, Datalab's run, no formula metric): text edit distance 0.114 English, 0.237 simplified Chinese, table TEDS 0.47. Throughput: 43.9 pages/s at 32 EPYC Genoa cores, 6.2 at 4 cores (one single-threaded worker per core); 25 to 51 pages/s on other 32-core containers. Median ~15% run-to-run variance admitted.

**Runtime.** Python >= 3.10, onnxruntime + OpenCV (headless) + pypdfium2 + huggingface_hub; no PyTorch, no GPU, no GGUF/ggml mention. Tested Linux x86_64/aarch64 and macOS Apple silicon (Windows not claimed).

**Honest limits (README).** Complex tables (merged cells, no ruling lines), handwriting, degraded scans, banner-shaped pages, many-diacritic Latin languages, vertical newspapers. "Built for speed on clean print."

**What it would take to run natively in Softanza's ggml engine** (engine today: `neural_gen.zig` llama/qwen2/qwen3/smollm decoder loop, BPE tokenizer, global single model slot via `embed.ggufHandle()`; `neural_embed.zig` BERT-family):
1. It is not a decoder LLM, so `neural_gen.zig` is irrelevant. The recognisers are small CTC conv/sequence nets: a new ggml graph per net (conv2d/pooling/normalisation + whatever sequence layer is inside, **operators UNVERIFIED until the ONNX graphs are inspected**) and a one-off ONNX/safetensors-to-GGUF conversion done offline by us (permitted only if the weights licence is accepted). Because the shipped path must be Python-free, **the ~170 KB of Python glue is the real cost**: detector post-processing and deskew (OpenCV), text-layer checks, RTL ordering, layout/reading-order post-processing, n-gram CTC beam search, markdown assembly, PDF text-layer reading. Roughly 8 to 10 modules (pipeline.py 45.6 KB, document.py 18.6, textlayer.py 14.9, layout_post.py 14.4, order_post.py 12.5, vocab.py 11.4, lm.py 10.4 ...) to port to Zig/Ring, plus a PDF renderer (pypdfium2) and an image decode/resize path, neither of which exists in the engine.
2. Eight networks (det, script, 4 rec, order, orient) means loading several small graphs at once: the engine has one global model slot, so a multi-model container is needed.
3. Size is excellent (76 MB, ms-scale CPU latency by Datalab's measurement) and is the only Datalab model that clearly fits a CPU-only laptop. The licence, not the engineering, is the blocker.

## 4. The rest of the family, one by one

### 4.1 Surya OCR 2 (the models Marker and Surya run on)
- HF `datalab-to/surya-ocr-2` (BF16 safetensors 1.37 GB), `datalab-to/surya-ocr-2-gguf` (GGUF 1.27 GB + mmproj 205 MB). Code `datalab-to/surya` (Apache-2.0). Weights $5M cap. https://huggingface.co/datalab-to/surya-ocr-2 , https://github.com/datalab-to/surya
- One VLM does layout + reading order + full-page OCR (HTML blocks with `data-label`, `data-bbox` normalised 0-1000) + table recognition (rows/cols, or full HTML) + inline math in `<math>` KaTeX tags. A separate small torch model (modified EfficientViT segformer, trained from scratch) detects text lines. `surya_layout2` is a separate faster RF-DETR layout detector (135 MB .pth, CPU/GPU).
- Architecture (config.json read): `Qwen3_5ForConditionalGeneration`; text 24 layers, hidden 1024, intermediate 3584, vocab 65,425, 8 heads / 2 KV heads, head_dim 256, tied embeddings, **hybrid: 3 `linear_attention` (Gated DeltaNet) layers then 1 `full_attention` layer** (linear conv kernel 4, 16 key/value heads, dim 128), `attn_output_gate`, partial rotary 0.25, interleaved **mrope** sections [11,11,10], MTP head (not needed). Vision: 12-layer ViT, hidden 768, 12 heads, patch 16, temporal patch 2, spatial merge 2, learned positions 2304, out hidden 1024, no deepstack.
- Training data: not stated on the card (UNVERIFIED).
- Benchmarks (Datalab's runs): olmOCR-bench 83.3 (8,413 tests; Chandra 2 85.9, dots.mocr 83.9, LightOnOCR-2-1B 83.2 "different methodology", olmOCR 77.4, GOT-OCR 48.3; comparison scores copied from the olmOCR-bench card). Per-source: ArXiv 88.3, Base 99.7, Hdr/Ftr 92.5, TinyTxt 93.7, MultCol 82.4, OldScan 41.8, OldMath 81.4, Tables 86.6. Internal 91-language benchmark: 87.2% overall; **French 89.3%, Arabic 72.7%**, Persian 82.3, Vietnamese 73.2, English 92.3 (internal, not independently replicable).
- Speed: 5.35 pages/s on one RTX 5090 (vLLM, concurrency 128, about 2,400 output tokens/page, 96 DPI); **0.108 pages/s on Apple Silicon with llama.cpp/Metal at parallel 8, 254 tokens/s aggregate, p50 59 s, about 30 W**. No CPU-only x86 and no 6 GB laptop-GPU figure is published (UNVERIFIED for our hardware). Rule of thumb from the published numbers: a page is about 2,400 decode tokens, so latency is dominated by decode speed, likely tens of seconds to minutes per page on a laptop CPU. That is a prediction, not a measurement.
- Runtime: `pip install surya-ocr`; vLLM (NVIDIA) or `llama-server` (llama.cpp; GGUF + mmproj). JSON-schema-guided layout decode (`SURYA_GUIDED_LAYOUT`). No official ONNX.
- **Engine work (largest and most reusable item):** (a) add a `qwen35` arch to `neural_gen.zig`: Gated-DeltaNet layer using `ggml_gated_delta_net` + `ggml_ssm_conv` (present in the vendored ggml header), plus the full-attention layers with output gate, partial-rotary and multi-section mrope (`ggml_rope_multi` present); (b) a **recurrent-state cache** next to the KV cache (state for 18 linear layers, KV only for 6 full-attention layers: this makes long contexts cheap); (c) vision tower: 12-layer ViT with conv patch embed (temporal patch 2: duplicate frame), learned position interpolation, 2x2 spatial merge to LM width, and a mmproj loader; (d) splice image embeddings into the token stream with 3D mrope positions; (e) a **second GGUF context** (LM + mmproj, or one container) -- the engine has a single global slot; (f) tokenizer: 65k-token vocab with its `tokenizer.json` (1.66 MB); GGUF probably carries it as GPT-2-style BPE, which the engine already parses, but the pre-tokenizer regex and added special tokens (image start/end, `<|im_start|>`) must be checked: UNVERIFIED; (g) page-image preprocessing (render at ~96 DPI, resize to patch multiples) and, for text lines, the EfficientViT detector (a second small net) if line boxes are wanted. The engine's existing GBNF grammar machine (`gbnf_machine.zig`) already fits Surya's guided layout JSON. File size 1.47 GB fits the budget on disk and on the 6 GB GPU.

### 4.2 Marker
- https://github.com/datalab-to/marker : PDF/Office/image to markdown/JSON/HTML. Pipeline of pdftext text layer + surya VLM (layout, OCR, tables) + small CPU models (OCR error detection); optional external LLM (Gemini, Claude, OpenAI-compatible, Ollama) for table merge/forms. Own olmOCR-bench: balanced mode 76.0% overall, 83.5% on born-digital (its README; Datalab's run). Code Apache-2.0; weights = the surya ones ($5M cap; the README says "$5M"). Marker is orchestration code, not a model: nothing to ship beyond what Surya needs, and Softanza would be re-implementing the same job.

### 4.3 Chandra / Chandra OCR 2
- https://huggingface.co/datalab-to/chandra-ocr-2 , https://github.com/datalab-to/chandra . 5.3B params, BF16 10.59 GB; Qwen3.5 arch (hidden 2560, 32 layers, vocab 248,320, ViT depth 24). Weights $2M cap + no-compete. Chandra 1: 8.77B, Qwen3-VL arch, 17.5 GB.
- olmOCR-bench 85.8 (Datalab's run, +/- 0.8; "Datalab API" 86.7); multilingual 43-language 77.8% avg (Datalab API 80.4, Gemini 2.5 Flash 67.6): **fr 93.7%, ar 68.4% (Gemini 2.5 Flash scores 84.4% on ar -- Chandra is *worse* than Gemini on Arabic in Datalab's own table)**. 90-language set: 72.7% vs Gemini 60.8%. Handwriting, forms/checkboxes, math, charts, image captions.
- Throughput 1.44 pages/s on one H100 80GB, vLLM, 96 sequences (Datalab estimates ~2 pages/s real-world). Runtime vLLM or HF transformers. Third-party GGUF/MLX/AWQ quants exist (e.g. prithivMLmods, shinshekai Q8_0).
- Does not fit the <= 3 GB budget at any sensible quantisation (5.3B at 4-bit is about 3 GB before the vision tower; UNVERIFIED size). Same qwen3.5 engine work as Surya, with 4x the LM.

### 4.4 lift (structured extraction)
- https://huggingface.co/datalab-to/lift : 9.65B, Qwen3.5 arch (hidden 4096), schema-constrained JSON from PDFs/images, multi-page. Own benchmark (225 documents, ~11,000 fields): 90.2% field accuracy, 20.9% full-document (Datalab API 95.9/44.4; Gemini Flash 3.5 91.3/40.0; NuExtract3 4B 81.5/8.4; Qwen3.5-9B 76.3/24.0). Weights $5M cap. Far over budget; no GGUF listed.

### 4.5 surya-parsebench-rl
- Research checkpoint, 0.67B, base surya-ocr-2, 70 RL steps. Datalab's own finding (card): rank moved 23rd to 3rd on ParseBench (run-llama) "almost all from formatting"; content faithfulness moved 0.4 points. Useful as a **warning that benchmark scores measure output conventions**, not as a model to ship. Card says "For OCR, use Surya OCR 2 or Chandra OCR 2".

### 4.6 pdftext, omni_parse_bench, omni_extract_bench
- pdftext (Apache-2.0, built on pypdfium2) is the model-free text-layer floor. The benches are Apache-2.0 code; OmniParseBench's `present` / `order` / `repeat` / `table_cell` / `layout_kind` test types are a good template for the golden tasks below (pass/fail, deterministic, tagged by ISO 639-3 language incl. `fra`).

### 4.7 Legacy (texify, surya v1 layout/table/detector/OCR-error models)
- CC-BY-NC-SA-4.0 weights; Texify code GPL-3.0 and archived. Not eligible.

## 5. Indra versus Docling (document intelligence)

| | Docling stack (as given in the brief) | Indra OCR |
|---|---|---|
| role | orchestration framework + models: layout RT-DETR ("heron", Apache-2.0), TableFormer, plug-in OCR (RapidOCR / EasyOCR / Tesseract), or the end-to-end VLM Granite-Docling-258M | **self-contained line-OCR + layout-label + reading-order pipeline**, no table-structure model (tables come out via layout labels + heuristics; table TEDS 0.47; cell grids are weak on complex tables) |
| model licences | Apache-2.0 (Granite-Docling card verified: https://huggingface.co/ibm-granite/granite-docling-258M) | code Apache-2.0, **weights modified OpenRAIL-M, $20M cap, no-compete** |
| sizes | Granite-Docling 258M (0.3B BF16): SigLIP2-base-patch16-512 vision encoder + Idefics3 pixel-shuffle projector + Granite 165M LM | 7.3M parameters total, 76 MB |
| languages | Granite-Docling: English primary; Japanese, Arabic, Chinese "experimental"; French *not mentioned* on the card | 95 languages measured for OCR, French in the Latin recogniser, Arabic via `rec_rtl` |
| runtime | PyTorch/transformers; llama.cpp/Ollama quants of Granite-Docling are listed on the card (16 variants) | ONNX Runtime, CPU |
| engine fit | Granite 165M LM is a llama-family arch the engine already runs; needs SigLIP2 ViT + projector + image tokens + page rendering | needs a CTC-net port + a large post-processing port, no LM |

Short version: **Indra competes with Docling's classical OCR + layout stages on CPU speed; it does not replace TableFormer, formula handling, or a VLM.** Granite-Docling is the Apache-licensed end-to-end alternative at a similar parameter order to Surya 2 (258M vs 650M). Docling heron / TableFormer licences and sizes I did not re-verify here.

## 6. One golden task per Datalab domain ("beats the floor")

Common rules: items are generated by the engine itself from known ground truth (no scraped data), fixed seed, fonts that ship with the project; floor = the best permissive thing we already have (named per task); a model "beats the floor" only if it wins on the mean *and* on at least 70% of items, with the margin stated up front. Checkers are pure string/geometry arithmetic -- no LLM judge.

1. **Line/page OCR (French + Arabic)** -- 20 items: 10 French (accents, ligatures, guillemets, e.g. "a l'ete") and 10 Arabic (with shaping, diacritics, digits) lines/short paragraphs rendered to PNG at 3 qualities (clean, 150 dpi, blur+noise). Format: `{image, truth_utf8, lang}`. Checker: NFC-normalise, strip whitespace, **character error rate** by codepoint Levenshtein; pass if CER <= 5% French / <= 10% Arabic; score = mean CER. Floor: Tesseract (fra / ara). Arabic uses logical order, as Indra emits.
2. **Digital-PDF text layer with fallback (Indra's hybrid)** -- 12 generated PDFs: 4 clean text layer, 4 Arabic with a visual-order (reversed) layer, 4 image-only. Format: `{pdf, truth_words}`. Checker: **word recall** = |truth words found / truth words| after NFC; pass >= 0.95; also assert that a reversed/garbled layer is *rejected* (recall of the layer < 0.5 must trigger OCR). Floor: pdftext/pypdfium2 text only.
3. **Layout and reading order (Surya)** -- 15 generated pages (2-column French article, sidebar, header/footer, a table, a figure) from known block rectangles with labels. Format: `{image, blocks:[{bbox,label,idx}]}`. Checker: greedy match by IoU >= 0.5; report label accuracy and the **Kendall tau** of matched blocks' reading order; pass tau >= 0.9 and label accuracy >= 0.85. Floor: XY-cut over text-layer line boxes (that is Indra's own no-order-model fallback).
4. **Table recognition (Surya table_rec / Chandra)** -- 15 tables rendered from known grids (ruled, unruled, merged header cell, French decimals "1 234,50", Arabic digits). Format: `{image, cells:[{r,c,rowspan,colspan,text}]}`. Checker: exact-match **cell F1** on `(r,c,text)` triples (TEDS-like but exact, no judge); pass >= 0.9. Floor: ruled-line detection + text-layer words assigned to cells.
5. **Math to LaTeX (Texify / Surya `<math>`)** -- 15 formulas (fractions, sums, matrices, sub/superscripts) rendered from known LaTeX. Format: `{image, latex}`. Checker: tokenise LaTeX, strip `\left \right` and spacing, **exact token-sequence match**; also validate parseable with a KaTeX-style parser (cf. Datalab's `pykatex`). Pass = exact normalised match; score = match rate. Floor: no permissive floor exists; report vs empty string, and vs Tesseract (expected near 0).
6. **PDF to markdown (Marker)** -- 12 PDFs generated from known markdown (headings, ordered/unordered lists, one table, a footnote, a bold span, French content). Format: `{pdf, tests:[present|order|table_cell|heading_level]}` modelled on OmniParseBench test types. Checker: each test pass/fail by substring/ordering/cell lookup; score = pass rate (>= 0.8). Floor: pdftext + font-size heuristic headings.
7. **Structured extraction (lift)** -- 15 synthetic French invoices/forms rendered from known JSON with 2 fields deliberately absent (must come back `null`) and one cross-page total. Format: `{pdf, schema, truth_json}`. Checker: per-field exact match after type normalisation (decimal comma, ISO date), null-for-absent counts as a hit; pass >= 0.9 field accuracy, and report full-document exact-match rate. Floor: regex/label-proximity extractor over the text layer.
8. **Handwriting (Chandra)** -- 10 items only, flagged as a weak proxy: lines rendered with open-licence handwriting fonts (script-like, French), with jitter and paper texture. Checker: **word accuracy** (case-folded exact words); pass >= 0.6. Floor: Tesseract. A real human-handwriting set is needed before any claim (PERCEPTGATE: unperceived is a state: nobody has looked at these renders yet).

## 7. Recommendation (what to do with this)

1. Keep every Datalab weight off the default shipped path: licence flow-down (Attachment A, Section 4(a)), per-user revenue/funding caps ($20M Indra, $5M Surya/lift, $2M Chandra) and the undefined no-compete clause make them non-permissive. Record them in the survey as "restricted weights, code Apache-2.0".
2. If one Datalab model is wanted for evaluation, take **Indra** (smallest, CPU-only, cap $20M) *as an optional adapter that downloads from Hugging Face on demand and shows the licence at install*, never vendored. Before any port, inspect the ONNX operator list (offline, with the user's consent to download 76 MB) and ask Datalab in writing whether a library offering OCR counts as "competing" under 2(c).
3. Of the family, **Surya OCR 2 (0.65B, 1.47 GB, GGUF, llama.cpp-proven)** is the only one that earns a place on size, and building the qwen3.5 text path + ViT in the engine would also serve other Qwen3.5-architecture models. That engine work is justified by the permissively licensed options only if one of them uses the same architecture: it is **not** justified by Surya alone, because of the licence.
4. Build the permissive floor first (golden tasks 1-4, 6 with Tesseract and pdftext), then try Granite-Docling-258M (Apache-2.0; llama-family LM already runnable; needs SigLIP2 ViT + projector). Add a restricted model only if it beats that floor by the stated margin.

## 8. Verified vs not verified

**Verified (primary source read live 2026-10-21):**
- The 14 GitHub repositories, their licences, stars and last-push dates (GitHub API listing).
- The 17 Hugging Face models, their licence tags, parameter counts (HF API `safetensors.total`), and file sizes (HF `tree` API) for surya-ocr-2, surya-ocr-2-gguf, indra-ocr, surya_layout2, chandra-ocr-2 (size via params), lift/chandra/parsebench-rl (params).
- LICENSE text and thresholds: indra-ocr $20M; surya-ocr-2 $5M; chandra-ocr-2 $2M (read directly); lift, surya-ocr-2-gguf, surya-parsebench-rl, surya_layout2 $5M and chandra $2M (grep of each LICENSE); diff of surya-ocr-2 vs chandra-ocr-2 LICENSE shows only the dollar figure differs; Sections 4, 5, 9 and Attachment A quoted.
- Indra README, CHANGELOG, `pyproject.toml`, `models.py`, `rec_preproc.py`, `lm.py`, parts of `pipeline.py`, config.json; Surya 2 and Chandra 2 and lift and parsebench-rl model cards; Surya 2 config.json (architecture numbers); Chandra/lift/parsebench-rl config.json (arch names, hidden sizes).
- Texify: HF licence cc-by-nc-sa-4.0, 169M params; GitHub `VikParuchuri/texify` GPL-3.0 archived.
- Granite-Docling-258M card: Apache-2.0, SigLIP2 + Idefics3 projector + Granite 165M, Arabic/Japanese/Chinese experimental, French not mentioned, quantised variants linked.
- Engine side (read in `D:\GitHub\_wti\libraries\stzlib\engine`, nothing written): `neural_gen.zig` known arch list is llama/qwen2/qwen3/smollm; GPT-2 byte-level BPE; single global model via `embed.ggufHandle()`; GBNF machine present; vendored `ggml.h` declares `GGML_OP_GATED_DELTA_NET`, `GGML_OP_SSM_CONV`, `GGML_OP_CONV_2D`, `GGML_OP_IM2COL`, `ggml_rope_multi`.

**Not verified / needs follow-up:**
- Indra network architectures, ONNX operator set and opset, the in-graph decode, and the training data (not published; ONNX files not downloaded).
- Any third-party replication of Datalab's benchmarks. All numbers above (OmniParseBench, olmOCR-bench runs, 91-language and 43-language tables, lift benchmark) are Datalab's own runs; competitor numbers in Datalab tables are partly copied from other repos (flagged by Datalab as "olmocr repo"/"dots.ocr repo").
- Surya 2 quantisation of the shipped GGUF (size implies 16-bit), the exact GGUF tokenizer/pre-tokenizer, and whether llama.cpp's qwen3_5 support covers the mmproj path on CPU only builds (Surya's README says llama.cpp CPU/Apple is supported, but I ran nothing).
- CPU-only or RTX 3050 6GB speed/VRAM for any of these models (not published; only RTX 5090, H100 and Apple Silicon figures exist).
- Whether Chandra/Surya/lift weights are fine-tuned from Qwen weights (and under which base licence); training data of every model.
- Legal reading of the licence (redistribution in an open-source library; meaning of "competes"); Datalab's pricing/commercial terms at datalab.to/pricing (not fetched).
- Docling's heron / TableFormer licences and sizes (taken from the brief, not re-read).
- The per-source dataset licences of omni_parse_bench (the README says "per source"; not read), and the contents of the `datalab-on-prem` and hosted API offerings.
- I did not find, and did not look for, a Windows wheel/support statement for `indra-ocr` (README claims Linux and macOS only).
