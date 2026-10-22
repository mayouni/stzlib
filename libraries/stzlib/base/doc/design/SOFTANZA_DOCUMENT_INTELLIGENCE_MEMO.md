# Document intelligence for Softanza — a decision memo on Docling

**Status**: DECISION MEMO, v0.1 · **Date**: 2026-10-21 · **Plane**: stzlib-intelligence · **Builds nothing.**
**Ref read**: `intelligence/model-flow` @ `main` a6a59d4f6 + engine commits 2f5dd6c33, 9c7514fc4, 13ea45735 (not `origin/main`, which has diverged).
**Evidence**: Docling's repo, documentation, technical reports and model cards, read 2026-10-21 by a research pass and **spot-checked by the author of this memo** (licences and parameter counts for Granite-Docling, the layout model, Indra and Qwen3 re-fetched live). Every claim is tagged `[page]`, `[repo]`, `[card]`, `[paper]`, `[code]` (read in this tree) or `[inferred]`. Anything not verified is in §7.
**Machine**: NVIDIA GeForce RTX 3050 6GB Laptop GPU, driver 561.00; a CPU the firmware often throttles (read `% Processor Performance` before quoting any time).

---

## 0. The decision, first

1. **Do not adopt Docling as a dependency.** It cannot ship on Softanza's path: every model stage runs through PyTorch, transformers or onnxruntime `[repo]`, and the serve image is 4.4–11.4 GB `[docs]`. It is legitimate as an **optional external faculty** for people who already have it — never implicit (LAW 2).
2. **Build the floor first, and the floor is not a model: a native PDF text-layer reader plus layout heuristics.** Softanza has no PDF code at all `[code]`. A born-digital PDF needs a parser, not a neural net.
3. **The best native model lever is Granite-Docling-258M** (Apache-2.0, a 165M llama-architecture decoder + a SigLIP2 vision tower, official GGUF published): its decoder is the family `neural_gen.zig` already runs; the vision tower and an embedding-prefill entry point are what is missing. It comes **second**, behind the floor, and only if it beats the floor on a golden page set.
4. **The RTX 3050 is an accelerator for the VLM and the encoders, never a requirement.** The route is Softanza's own wgpu plane, not a vendored CUDA runtime.
5. **Nothing here has been measured against a floor, because no floor exists yet.** §6 says what can and cannot be measured today.

---

## 1. Docling's real architecture

### 1.1 What the page said — and did not
The page `docling.ai/blog/20261016_00_docling-on-nvidia-rtx-spark/` `[page]` is a launch note dated 16 Oct 2026, no author. Every claim in the prior summary is on it: PDF/DOCX/PPTX/scanned images → structured Markdown/JSON preserving layout, tables, headings, reading order; GPU-accelerated OCR, layout, table-structure and VLM backends; a CUDA build of PyTorch is "all it takes"; local agent stacks pair it with Ollama/LM Studio/vLLM and expose a usage skill and an MCP server; the same API targets a local install, `docling-serve`, or IBM watsonx. **It names no model, no number, no licence.** It is marketing for a Python + PyTorch stack. Everything below came from the repository, the docs, the papers and the model cards.

### 1.2 Project facts
Docling is **MIT** `[repo]`; v2.141.0 released 2026-10-20. `docling-parse`, `docling-ibm-models`, `docling-serve` and `docling-mcp` are MIT `[repo]`. It is a Python package; torch and `docling-ibm-models` are optional extras `[repo: pyproject]`.

### 1.3 Pipelines and the model behind each stage

| Pipeline / stage | Model | Licence `[card]` | Size | Runtime |
|---|---|---|---|---|
| PDF parser backend | `docling-parse` (C++20, CMake) / pypdfium2 | MIT | ~1.8 MB C++ source, ~10 sub-dependencies (qpdf, libjpeg, openjpeg, lcms2, freetype, blend2d, pdfium_jbig2, utf8, nlohmann json, loguru, cxxopts) `[repo]` | native, pybind11 |
| Layout | `docling-layout-heron` — **RT-DETRv2**, 640×640 input, 17 classes | **Apache-2.0** (re-fetched live) | **42,889,979 params** (re-fetched live); official ONNX 171 MB | PyTorch / ONNX |
| Table structure | **TableFormer** v1 (`ds4sd/docling-models`): ResNet-18 backbone at 448 px, 6-layer encoder + 6-layer decoder, 8 heads, hidden 512, bbox head | two tags on the card (cdla-permissive-2.0 **and** apache-2.0) with no statement of which applies to which file | accurate 213 MB, fast 145 MB (F32) | PyTorch |
| OCR | `OcrAutoOptions`: RapidOCR / EasyOCR / Tesseract / others | RapidOCR Apache-2.0 (ONNX models); Tesseract Apache-2.0; EasyOCR is the slow one (30+ s/page on CPU `[paper]`) | not stated on any page read | ONNX / PyTorch / native |
| VLM pipeline | **Granite-Docling-258M** (Idefics3: SigLIP2 vision tower of 12 layers + a 30-layer llama decoder, hidden 576, 9 heads, 3 KV heads), output **DocTags** | **Apache-2.0** (re-fetched live) | 257,517,120 BF16 params (re-fetched live); 515 MB BF16; **official GGUF: BF16 332 MB + 190 MB projector** | transformers / MLX / vLLM / Ollama / LM Studio / llama.cpp |
| (older VLM) | SmolDocling-256M | the card gives conflicting licences | — | — |
| Simple pipelines | DOCX/PPTX/XLSX/HTML/Markdown/CSV | — | — | no neural model: zip + XML |

Formats in: PDF, DOCX, PPTX, XLSX, HTML, Markdown, CSV, images (and an ASR pipeline). Formats out: the `DoclingDocument` JSON, Markdown, HTML, DocTags, text `[docs]`.

### 1.4 Cost
Published numbers exist only for the Python stack `[paper/docs]`: **1.27 pages/s on an M3 Max and 0.60 on a Xeon E5-2690** (native backend, no OCR); a GPU guide gives **4.2 pages/s on an RTX 5070 against 1.2 CPU-only** on the same machine, and Granite-Docling through a server 2.0 pages/s on the 5070. **There are no VRAM figures, no RTX 3050 figures and no CPU VLM figures.** I am not estimating them. The VLM's cost is driven by decode length: Docling's defaults allow 4,096 new tokens per page `[docs]`.

### 1.5 `docling-serve`, the MCP server and the skill
`docling-serve` is a REST API (convert source/file, async tasks); the MCP server and usage skill expose the same. It is a process you run — Docker or a Python environment — and a **service call** in Softanza's governance vocabulary (capability `sensing`, posture `:local` or `:live`).

---

## 2. What Softanza has for documents today `[code]`

| Capability | Present | Absent |
|---|---|---|
| Files, zip | file ops; `stzZipFile` — **extracts to disk only** | in-memory entry reads |
| XML / HTML | XML parser with exclusive C14N and query paths; an HTML DOM; markdown handling | OOXML (DOCX/PPTX/XLSX) *readers* — only the pieces |
| **PDF** | **nothing** — a `grep` for pdf finds a router keyword list, a Unicode bidi class name and a polyglot example | reader, renderer, generator |
| Images | stb decode vendored, **used only inside `gpu_render.zig`** | analysis: no thresholding, morphology, connected components |
| OCR | none in-engine. **Measured platform floor:** `Windows.Media.Ocr` — French exact on a rendered 2-line PNG (9 words, 10 ms, with boxes); Arabic: second word exact, first word split at a shaping gap, and returned in visual order. Not wired to any class | OCR faculty |
| Tables | `stzTable` (~2,500 definitions), pivots, columnar engine | table *recognition* from an image or a PDF |
| Text | the linguistic tier, C9 structured output, `stzLLMFunction`, semantic index | — |
| Producing documents | `stzCanvas`, SVG, plots, diagrams, text shaping incl. Arabic | — |
| Neural | decoders llama/qwen2/qwen3/smollm, BERT encoders, reranker, NER head, GBNF constrained decoding; one model slot | vision tower, audio encoder, **a decoder entry that takes embeddings**, cross-attention, beam search |

**The honest summary**: Softanza is strong at *producing* documents and at everything *downstream* of text (C9 extraction, summaries, retrieval). It has **no way to get text out of a PDF or an image**. The ingestion half is a void, not a weak floor.

---

## 3. The constraint, and the options compared

The constraint: the shipped path has **no Python and no PyTorch**; the engine is Zig with a vendored **CPU** ggml; a GPU may help but must never be required. The vendored ggml already compiles the conv, pool, upsample, group-norm, `gelu_erf`, `flash_attn_ext` and window ops `[code]` — so a missing capability is **missing graph code in Zig, not a missing kernel.**

| | (i) native pipeline in the engine | (ii) a document VLM as a GGUF through the engine | (iii) Docling / `docling-serve` as an optional external faculty | (iv) hybrid |
|---|---|---|---|---|
| **What** | PDF reader → layout → table → OCR, each stage native | Granite-Docling-258M end-to-end: page image → DocTags | a `:service` implementation behind the flow's port, with the floor beneath | native PDF text-layer **floor**; VLM and Docling as *measured* upgrades |
| **Engine work** | very large: see §4 | medium: vision tower, embedding-prefill entry point, preprocessing, DocTags converter | small: an HTTP client faculty (the engine has libcurl/mbedTLS) | the sum of the floor + (ii) |
| **Risk** | high — PDF parsing, deformable attention, TableFormer post-processing | medium — it is checkable token-by-token against llama.cpp | low technically; **LAW 2 posture**: external, optional, never implicit | medium, staged |
| **Dependency** | none | none beyond the GGUF (Apache-2.0) | Python + PyTorch (+ optional CUDA) on the *user's* machine | none for the floor |
| **RTX 3050 role** | optional accelerator for detector/tower prefill | prefill of the ViT (compute-bound) benefits; decode of 165M is cheap on CPU | whatever the user's PyTorch does; this machine would use CUDA PyTorch | optional |
| **Sovereignty / offline** | full | full | the *service* is local, but the install is not Softanza's | full for the floor |
| **When it wins** | the long run | scanned/complex pages once the floor exists | users who already run Docling; a ground-truth oracle for our golden sets | now |

### 3.1 Governance posture of (iii)
A Docling call is **`sensing`**, not `inference`: it is a process or endpoint outside the engine. It is a `:service` implementation (design §4.1): **never selected implicitly**, only when pinned by name, posture declared, budget mandatory, its parcel a *proposal* that a gate or rule admits. Its output validates through the same `:document` court as any other implementation's.

---

## 4. Which stages are feasible natively (with ggml on CPU) `[repo/code/inferred]`

| Stage | Reference | What the engine lacks | Effort / risk |
|---|---|---|---|
| **PDF text/glyph/cell extraction** | `docling-parse` (MIT, C++20, ~10 deps) — **not vendorable safely**: the engine's `vendor/ggml/NOTICE` records that C++ static constructors **do not run** in its Windows DLLs, and this code is C++20 with exceptions and statics | a **native Zig PDF reader**: xref + object streams, Flate (zlib is vendored), a content-stream interpreter with text/graphics state, fonts (simple, ToUnicode, CID, embedded programs for widths), output as positioned chars → words → lines | **large / high**, but dependency-free, **and testable against docling-parse as an oracle** |
| Page → bitmap (for the 640×640 layout input and for scans) | pdfium in Docling | a rasteriser over outlines/paths, or reuse of the canvas stack; JPX/JBIG2/CCITT decoders for scanned PDFs (stb has none) | large |
| **Layout (RT-DETRv2, 42.9M)** | HF `RTDetrV2` | conv backbone ✔ in ggml; hybrid encoder ✔ (attention); the **deformable cross-attention sampling** (`grid_sample`) — the paper's *discrete* decoder method reduces it to gathers; box decode glue; a converter | medium–large / medium |
| **TableFormer** | `docling-ibm-models` (MIT) | cross-attention over image features, beam search, a bbox head, OTSL→table post-processing (Python, to be ported by hand) | medium–large / medium (decoder wiring unverified) |
| **OCR** | RapidOCR (Apache, ONNX) / Tesseract (Apache, C++) | RapidOCR: DB detection + CTC recognition — convs mostly in ggml, plus a polygon post-process; Tesseract: C++ static-init risk, large | medium / medium |
| **Document VLM** | Granite-Docling-258M | the **SigLIP2 tower** (12 layers, hidden 768, patch 16, a strided-conv patch embed — closest existing code is the BERT-style encoder in `neural_embed.zig`), a pixel-shuffle connector, image tiling/normalisation, **a decoder entry that accepts embeddings** (today it takes token ids only: `ggml_get_rows(token_embd, tokens)`), and DocTags conversion | **medium / medium** |
| OOXML (DOCX/PPTX/XLSX) | zip + XML | an in-memory zip reader + a structure builder; **no model** | small–medium / low |

Risk order, highest first: native PDF parsing → Tesseract vendoring → TableFormer post-processing → deformable sampling → VLM tower → OOXML.

**An asset worth stating**: the engine's constrained decoder (`gbnf_machine.zig`) can constrain a VLM's output to *well-formed DocTags*. That is the house idea — structure kills malformedness — applied to documents, and it is a capability the Python stack does not have for free.

---

## 5. Recommendation — the minimal vertical slice, and how it appears in the flow

**Slice D1 (the floor, no model):** `bytes → pages → text regions → reading-order text`, for **born-digital PDFs**, in Zig:
1. A PDF reader giving **positioned characters** (xref, Flate, content streams, ToUnicode fonts).
2. **Layout by heuristics over positions**: group characters into words and lines, detect columns by gaps, mark headings by size/weight, header/footer by repetition across pages.
3. An `stzDocument` of pages → regions (kind, box, order, text).
4. Downstream, unchanged: `:extract` (C9), `:summarise`, `:classify`, `:embed` + `:rerank` for retrieval.

In the flow design (§15 of `SOFTANZA_MODEL_FLOW.md`) these are faculties: `:document-pages` (floor = the reader), `:document-layout` (floor = the heuristics), `:document-table` (floor = alignment/ruling heuristics), `:ocr` (floor = `Windows.Media.Ocr` on Windows, **refuses** elsewhere — and says so). Each later model (RT-DETR layout, TableFormer, RapidOCR, Granite-Docling) is an **implementation of the same faculty**, selected only by **beating the floor on the document golden set** (design §9.2).

**Slice D2 (the first model, after D1 exists):** Granite-Docling-258M as the implementation of `:document-pages → :document` for *scanned or complex* pages — the tower, the embedding-prefill entry, DocTags under grammar. It needs the **second model slot** (decoder + projector) — design §11 (A5).

**Slice D0 (parallel, small, no model):** OOXML (DOCX/PPTX/XLSX): an in-memory zip reader + structure. This is the other "document" half and has no model risk.

The three slices share the `:document` parcel type; D1's golden pages can be **generated by Softanza itself** (the canvas/SVG stack produces pages with exact ground truth), which is how a deterministic checker exists without an LLM judge.

---

## 6. Measured baselines (2026-10-22)

**There is still no floor**: Softanza cannot read a PDF, so the numbers below are the bar a native reader will have to meet, not a comparison.

**The golden set** `base/test/document/_data/golden_v1/`: 10 PDFs rendered by headless Chrome from HTML, each with an `expected.json` (headings, key sentences in reading order, table grids, list items, page furniture, code). It was written by a separate agent that never ran an extractor, and the metrics in `base/test/document/_docling_baseline.py` were fixed before Docling's output on it was seen.

**Docling 2.141.0, OCR off, CPU** (`results/docling_baseline_golden_v1.md`): text 0.97, reading order 1.00 (the two-column page included), headings 1.00, tables 0.95, lists 1.00, furniture kept out of the body 1.00, code 0.00. 239 s for 10 documents, 83 s of them the first document's model loading. Its two failures are real, checked against its output:

- **code**: the block is found and labelled `code`, but `mass_kg` comes out as `mass _ kg`, so the text is not the code.
- **Arabic**: every French sentence is found, but the right-to-left paragraph's lines come back reordered and spliced, so 2 of the 3 Arabic sentences are lost. **Bidi is where a Softanza reader can beat Docling**: the graphics plane already shapes and orders RTL text.

**OCR on a real scan** (one page, no text layer, a French attestation supplied by the author; never committed): RapidOCR through Docling, 55 s on CPU, the whole body text recovered with its accents, one missing space. The logo, the stamp and the footer band are not in the exported text (pictures and page furniture). Perceived by Claude against the rendered page, then read by the author, whose document it is: **"it's good"** (Mansour Ayouni, 2026-10-22).

**How it ran**: the venv is outside the tree (`D:\GitHub\_wt_dl\docling-venv`, plus `onnxruntime` for RapidOCR), and the models were fetched beforehand with `curl -C -` and checked against the hub's SHA-256 (layout 171,658,996 B `00333a43...`, TableFormer accurate 212,758,388 B `2a7d6c92...`), because the Hugging Face client stalled on this network. Run with `--artifacts <models dir>` and `HF_HUB_OFFLINE=1`.

**Not measured**: Granite-Docling-258M (not downloaded), the GPU, scanned golden pages with an expected text.

---

## 7. Verified vs not verified

**Verified live by the author of this memo (2026-10-21):** Granite-Docling-258M is Apache-2.0, `idefics3`, 257,517,120 BF16 parameters; `docling-layout-heron` is Apache-2.0, `rt_detr_v2`, 42,889,979 parameters; Indra's weights are a modified OpenRAIL-M with a $20M funding/revenue cap and a no-compete clause, code Apache-2.0; Qwen3-4B-Instruct-2507 is Apache-2.0, `qwen3`, 4.02B parameters.
**Read in the tree:** the engine's lack of PDF/OCR/OOXML code, the token-id-only decoder entry, the C++ static-initialiser NOTICE, the one model slot.
**From the research pass, not re-verified:** TableFormer's internal wiring (the `tablemodel04_rs` source was not read); the published pages/s figures; the official Granite-Docling GGUF file sizes; whether Granite uses extra scale multipliers (the config says `llama`); RapidOCR model sizes and which Paddle models exist for Arabic/French; ONNX operator coverage of the layout model.
**Not tools-checkable here:** any claim of the form "faster than" on this machine. No time was taken on this machine for any document stage.
