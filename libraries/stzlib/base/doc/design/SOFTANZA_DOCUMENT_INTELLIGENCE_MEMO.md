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

**The floor now exists (2026-10-22): Softanza's native reader**, `engine/src/pdf.zig` in `stz_file.dll`, Zig standard library only, with its Ring face `base/file/stzPdf.ring`. It reads the text layer: objects (a broken xref does not matter), object streams, five filters, ToUnicode and simple encodings, the text and path operators; then lays the glyphs out (rows, right-to-left lines in logical order, tables from ruling lines, an XY cut for columns) and types each block. Guard `pdf_reader_narrated.ring`, 42 assertions.

**Measured on golden_v2**, 12 harder PDFs written by a second independent agent that saw neither reader nor golden_v1 (borderless table, three columns, a sidebar, a table across two pages, Hebrew, a scientific page, a form, bold-only headings, a) b) lists, German with a soft hyphen, landscape, code with tabs). Both readers write the same prediction format and are scored by the same function, `_doc_score.py`:

| golden_v2 | text | order | headings | tables | lists | furniture | code | per document |
|---|---|---|---|---|---|---|---|---|
| Softanza native | **0.97** | **0.99** | 0.94 | 0.66 | **1.00** | 0.25 | **1.00** | about 2 ms |
| Docling 2.141 | 0.96 | 0.97 | **1.00** | **0.89** | 0.00 | **1.00** | 0.50 | about 5 s |

On golden_v1 the native reader scores 1.00 everywhere, but golden_v1 is its DEVELOPMENT set (it was built while reading those ten files), so that number proves behaviour, not quality; only golden_v2 is a measurement. **golden_v2 is now spent the same way the moment the reader is changed to fix what it showed**: a fix is re-measured on a new set.

What the native reader got wrong on golden_v2, each cause read off its output:

- **tables**: a table WITHOUT ruling lines is not found (e01, 0.00; its text is still read, in order); a table continued on a second page comes back as two tables (e04, 0.62).
- **furniture**: a running header or a form's footer on a ONE-page document has no repetition to give it away (e06, e07); Docling's layout model sees it.
- **headings**: numbered headings ("1. Introduction") were taken for list items, because the list-marker rule runs before the heading rule (e06).
- **bidi**: in Hebrew, the period after a Latin run at the end of a sentence lands on the wrong side of it (".Rivulet S3"), a weak-character rule the line reordering lacks (e05).
- **hyphenation**: a word split by a soft hyphen across a COLUMN break is not joined (e10).

What Docling got wrong on the same set: every a) b) c) list (lists 0.00), the code block with tabs (0.50), two of the six Hebrew sentences, the reading order around the German column break, and the same two-page table (0.62).

**Second round, the same day: the six misses fixed, then measured on golden_v3.** The fixes, each general and each pinned in the guard (60 assertions): a table without ruling lines is found from aligned columns of short cells (rows in one type size); a table continued on the next page is joined and its repeated header dropped; two columns must stand side by side, a column's tail below the other column ends it, and a narrower column in smaller type is an aside read after the main flow; a short line in smaller type in the page's margin band is furniture even on a one-page document; a numbered line set larger or bold is a heading, not a list item; in a right-to-left line, spaces are found between glyphs that are neighbours ON THE PAGE before the line is reordered, and punctuation joins a left-to-right run only inside it; a word broken by a hyphen at the end of a line or a column is joined to its other half; a heading in larger type than the table under it is not its caption. After the fixes both development sets read 1.00 on every metric -- which is what a development set is for, and not a measurement.

golden_v3: 14 PDFs by a THIRD independent agent that saw neither reader, nor golden_v1 or v2, aimed at the same families of difficulty with new layouts. The reader was frozen before it was run; both readers were run once:

| golden_v3 | text | order | headings | tables | lists | furniture | code | per document |
|---|---|---|---|---|---|---|---|---|
| Softanza native | **0.90** | 1.00 | 1.00 | **1.00** | 0.80 | 1.00 | **1.00** | about 2.5 ms |
| Docling 2.141 | **0.90** | 1.00 | 1.00 | 0.89 | **1.00** | 1.00 | 0.50 | about 3.9 s |

What golden_v3 shows, causes read off the outputs: **both** readers lose the same three things -- a word with soft hyphens in a narrow column, which Chrome draws as syllables a few points apart, so both readers write "re spon si bil i ties" (f10, 0.125 for both); the sentence ending in "(KPI)" in Hebrew, where the parentheses need mirroring (f08); the sentence holding a word broken across a column break, in a monospaced page (f09). **Only Docling** splits the two-page table (f03, 0.56; the native reader now joins it, 1.00) and loses half the code (f14, 0.50). **Only the native reader** misses typed "→" list markers (f12, lists 0.60) and a ligature it leaves as U+FB01 "ﬁ" where Docling writes "fi" (f14). Fixing these spends golden_v3: they are re-measured on a golden_v4.

**Third round, the same night: golden_v3's misses fixed, then measured on golden_v4.** Fixed, each general and pinned in the guard (69 assertions): a space glyph another glyph is drawn over is an invisible soft hyphen (Chrome writes U+00AD as a space and draws the next syllable back over it) and is dropped, so words are no longer cut into syllables; brackets outside a Latin run in a right-to-left line are mirrored; prose set in a monospaced font is prose, not code; a typed arrow starts a list item; ligature code points read as their letters. Only what golden_v3 showed was fixed: the brief of golden_v4 was written by this desk, and building for its categories in advance would have been teaching to the test.

golden_v4: 16 PDFs by a FOURTH independent agent (soft hyphens that do and do not break, ligatures, Arabic and Hebrew with brackets and guillemets, typed list markers, roman-numbered lists, three columns, merged and borderless tables, a two-page table, four heading levels, a pull quote, small caps, a line-numbered listing, French typography, a mixed layout). The reader was frozen before it ran; both readers ran once:

| golden_v4 | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native | **0.98** | 1.00 | 0.92 | 0.70 | **0.73** | 1.00 | **0.50** |
| Docling 2.141 | 0.69 | 1.00 | **0.97** | **0.90** | 0.13 | 1.00 | 0.00 |

The native reader read every document in 6 to 31 ms; Docling took 5 to 59 s on the same run (the machine was slower that night than in the earlier rounds, for both). Docling's text falls to 0.69 on the soft hyphens and ligatures the native reader now handles. **What the native reader got wrong on golden_v4**, causes read off its output: guillemets « » are not mirrored in Hebrew (g04); typed "✓" and roman-numeral markers "i." "ii." do not start list items (g05, g06); a borderless table with right-aligned numbers collapses to two columns (g09); a table continued on page 2 is not joined when a page footer sits between its halves in reading order (g10); headings marked by italics alone are paragraphs (g11); a letter-spaced heading comes out as spaced letters (g13); a code listing with a line-number gutter breaks into seven blocks (g14); an Arabic heading is not found (g03); two sentences of a two-column section that follows a full-width table are missed (g16). These are round 4, to be measured on a golden_v5.

**Fourth round: golden_v4's misses fixed, then measured on golden_v5 -- the first set of REALISTIC documents.** Fixed and pinned in the guard (87 assertions): cell boundaries between close, right-aligned figures; letter-spaced text; italic-only headings; line numbers in a code gutter; a table split by page furniture; the aside test on medians; a column ending at the first gap below the other column's end; a sentence running on into the next column; compounds keeping their own hyphen; Arabic-or-Persian decided over the whole document; guillemets mirrored; typed check marks and roman numerals as list markers.

golden_v5 was briefed differently from v2-v4: not one difficulty per document but whole documents an office, school, clinic or administration produces -- an NGO annual report (3 pages), a French business letter, an invoice, a Portuguese receipt on a narrow page, a landscape school timetable, board minutes, a product datasheet, a three-column newsletter, a technical note with footnotes and code, a two-page application form, a French and Arabic notice side by side, a four-language safety leaflet, a Swahili and English schedule, an IT runbook, a memo, a German bus timetable, a financial statement, a Turkish lab report. 18 PDFs by a fifth independent agent; the reader was frozen (2498ba92e) before it ran; both readers ran once:

| golden_v5, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native | 0.91 | 0.95 | **0.74** | 0.60 | 0.52 | 0.79 | **1.00** |
| Docling 2.141 | 0.91 | **1.00** | 0.70 | **0.84** | **0.58** | **0.95** | 0.13 |

**This is the most informative number of the series, and it is not flattering.** On single-difficulty documents the native reader overtook Docling; on whole realistic documents it ties on text, keeps its lead on headings and code, and falls clearly behind on tables (0.60 against 0.84) and page furniture (0.79 against 0.95). Causes read off its output: a real table is cut into pieces -- the invoice's 13 x 5 table comes back as four tables, the lab report's 12 x 5 as three, the financial statement's 16 x 6 as two -- because totals rows, section rows and partial rulings make separate ruling groups; a two-column specification table is not found at all; a letterhead or a legal footer of several lines, or set in body-size type, is not furniture on a one-page letter. Many expected "lists" have no visible marker (dated event lines, "[1]" references, "R = ..." legends): they are lists in the HTML source, and Docling also scores 0 on those documents -- partly an ambiguity of the set, not only a gap of the readers. These are round 5, to be measured on a golden_v6 of realistic documents.

**Fifth round: tables and furniture of realistic documents, then golden_v6.** Fixed on golden_v5 (now a development set; there tables 0.60 -> 0.81, furniture 0.79 -> 0.90, headings 0.74 -> 0.83): tables carry their column bands and grow by header rows above (spanning cells fill each column, past one section row) and totals rows below (the label fills the cells it spans); tables stacked with the same columns are one; a prose line of a neighbouring column is never a cell; a Type3 font's widths use its own FontMatrix (Chrome's synthetic bold: read as thousandths its spaces were taken for soft hyphens) and fill-and-stroke text is bold; the full NFKC mapping of the Arabic presentation forms, generated from Unicode 15.1; run-in headings; typewriter headings; small-type footers of any length. Guard 102 assertions.

golden_v6: 20 realistic documents (a quotation, a purchase order, a payslip, a bank statement, an electricity bill, an Arabic report card, a discharge summary, lab results, a prescription, a project report, a call for tenders, board minutes, a two-column policy, a user guide, a product catalogue, a conference programme, an itinerary, a Hausa certificate, a stock sheet, a four-language notice), eight languages besides English, eleven of 2-3 pages, by a sixth independent agent; reader frozen at e8f8dd773; both readers ran once (Docling in resumable pieces, the machine throttled to 42 per cent for part of it):

| golden_v6, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native | **0.94** | **0.99** | **0.98** | 0.50 | **0.72** | 0.51 | **1.00** |
| Docling 2.141 | 0.88 | 0.98 | 0.87 | **0.70** | 0.67 | **0.73** | 0.67 |

The native reader now leads on text, order, headings, lists and code on unseen realistic documents, and still trails on **tables** and **furniture** -- and the table gain made on golden_v5 (0.81) did NOT carry over (0.50): it was partly fitted to that set. Causes read off the output: a page-spanning table is still cut in two when its halves differ (a 42-row purchase order comes back as 18 + 21 rows; a bank statement as two tables with different column counts); small key/value tables side by side are merged into one wide table (a payslip's three become one 16 x 4); a letterhead of several lines in body size or larger (company name, street, town) is not furniture, which Docling's layout model sees. Round 6, measured on a golden_v7 of realistic documents.

**Sixth round: header bands, page-spanning tables, letterheads; then golden_v7.** Fixed on golden_v6 (now a development set; there tables 0.50 -> 0.61, furniture 0.51 -> 0.73): a table's header gathered as a band of lines (wrapped cells joined per column, several cell-lines as several header rows, cells short, a further row close above); totals labels filled across the cells they span in every table; a letterhead's capitals logo and short address lines ending above the title are furniture. A side-by-side split of borderless tables was tried and REMOVED: it did not fire on the payslip it was written for and cost elsewhere. Known limit: a row span in a borderless header is not inferred. Guard 111 assertions.

golden_v7: 20 realistic documents in 11 languages besides English (a hotel invoice, a rental contract, a customs declaration, an Arabic patient leaflet, a Swahili timetable, a transcript, a league table, a Turkish train timetable, an A3 research poster, an NGO report, a Hausa extension sheet, cooperative accounts, a municipal budget, election results, a receipt, an exam paper, a veterinary record, an insurance schedule, a Hebrew listing, a cargo manifest), 10 of 2-3 pages, by a seventh independent agent; reader frozen at a13d04600; both readers ran once:

| golden_v7, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native | **0.99** | **1.00** | **0.98** | 0.68 | 0.55 | 0.53 | **0.50** |
| Docling 2.141 | 0.81 | 0.99 | 0.71 | **0.72** | **0.63** | **0.72** | 0.25 |

The native reader keeps a wide lead on text and headings on unseen documents, draws level on tables (0.68 against 0.72, from 0.50 against 0.70 on v6), and **trails on furniture again (0.53 against 0.72): the letterhead gain on golden_v6 did not carry over.** The cause is visible: on receipts, posters and club letters the organisation's name is the LARGEST text on the page, so the rule takes it for the title, and nothing ends above a title; golden_v7 marks those blocks as furniture, and so does Docling's layout model, which has seen many such pages. A deterministic floor can only meet this with a stated convention (the first block group of page 1, set apart by a gap, is a letterhead when it holds an address or a legal line), and that convention will be wrong on documents whose name is their title -- the honest place for this judgement may be a measured model above the floor, not the floor. Tables still missed: a three-column poster's narrow table, a Hausa sheet's small table, a receipt's items split in two.

**The letterhead decision as a measured faculty, and round 7 on golden_v8 -- now under Ring++.** Ring is retired (the author, 2026-10-23): the reader and its guards run on Ring++ (`rnxc`), against the Rule-A-migrated library, with every engine DLL built for Ring++'s native interface (`rpp_init`) from this tree's sources by Ring++'s own `bench/engine_copy.py`. The PDF guard passes 111 of 111 under Ring++, and the letterhead floor scores the same under Ring++ as under Ring (128 of 167).

The **:letterhead faculty** (`base/file/stzPdfLetterhead.ring`) decides, for each block of page 1's top band, letterhead or content. Its floor is the reader's own rule; each installed generative model reads its probability for the two answers; the registry takes a model only if it measures strictly better than the floor. Golden set: the 167 top-band blocks of golden_v7 (fixed before any rule or model was tuned to it), labelled from that set's own furniture lists: 55 letterhead, 112 content.

| letterhead, 167 blocks of golden_v7 | score | chosen |
|---|---|---|
| reader's rule (floor) | **0.77** | **yes** |
| Granite-4.0-1b, read by probability | 0.71 | no: below the floor |
| Qwen2.5-Coder-1.5B, Granite-4.2-3B | not measured | -- |

The two larger models are NOT measured yet: the CPU was firmware-throttled to 21 per cent for the rest of the day (an item took 45 to 90 s, so one model needed more than two hours), and another repository's engine build ran meanwhile. Until a model beats 0.77, the registry answers with the floor -- so "the reader plus the decision" is, today, the reader.

golden_v8: 24 realistic documents in 10 languages besides English, 12 of 2-3 pages, 20 with a letterhead, four tables across pages, by an eighth independent agent; reader frozen at the round-6 state; both readers ran once:

| golden_v8, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **1.00** | 1.00 | **0.99** | 0.64 | **0.83** | **0.56** | **1.00** |
| Docling 2.141 | 0.84 | 1.00 | 0.84 | **0.75** | 0.78 | 0.55 | 0.25 |

Across eight sets the pattern holds: on unseen realistic documents the native reader leads on text, headings, lists and code by a wide margin and at a thousandth of the time; it is level on reading order and on furniture (both readers are weak there); it trails on tables by about a tenth. Furniture is where a measured model above the floor has room, and the faculty is in place to take one when it earns its place.

**Eighth round: borderless tables; then golden_v9.** Fixed on golden_v8 (now a development set; there tables 0.64 -> 0.67; golden_v7 tables 0.67 -> 0.68; golden_v1 to v4 stay at 1.00 on every metric): in a borderless table a cell's column is the column its centre falls in; blank rows above a table's first row with text are a band (a double border, a header's background) and are dropped, while blank rows further down are kept (a form's empty rows to fill in are part of the table). Tried and WITHDRAWN, each measured on golden_v1 to v8 before it was kept or dropped: a wrapped one-cell line joining a run of rows (it pulled prose into tables), a five-word bar for a cell (it let short prose in: golden_v2 and v3 text 1.00 -> 0.94), columns taken from the fullest rows (golden_v5 tables 0.81 -> 0.77). Guard 116 assertions under Ring++.

golden_v9: 24 realistic documents in 14 languages besides English (among them Amharic in Ethiopic script, Hebrew and Arabic), 15 of 2-3 pages, two long tables across pages, six code or configuration blocks, page numbers in seven forms, by a ninth independent agent (who saw no reader, no output and no earlier set, and who did not look at the rendered pages either -- the set is unperceived); reader frozen at 41ccfbf7c; both readers ran once (the CPU firmware-throttled to 21 per cent, so Docling's seconds are slower than its nominal):

| golden_v9, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | 0.93 | **0.99** | **0.96** | 0.62 | 0.59 | **0.62** | **0.63** |
| Docling 2.141 | **0.97** | 0.98 | 0.92 | **0.67** | **0.76** | 0.60 | 0.00 |

Time for the 24 documents: native 1.2 s, Docling 2,703 s (throttled). **For the first time since golden_v3, Docling leads on text** (0.97 against 0.93), and it keeps its lead on tables and lists; the native reader keeps order, headings, furniture and code. The round-8 table gain on the development set (0.64 -> 0.67) is matched on the unseen set (0.62, against 0.64 on v8 before the fixes): it neither carried a large gain over nor lost one. Causes read off the native output: **side-by-side boxes are read line by line across both boxes** instead of box by box -- an English column and its Hausa translation (text 0.38), an Amharic card with its English beside it (0.57), a text and a tinted box beside it (0.83), a two-column newsletter around a spanning table (0.57); this one class is most of the text loss, and it is round 9's first item. Tables: a menu's four small price tables and a flyer's 4 x 3 table are not found at all; the two long tables across pages are still cut (59 rows come back as 16 + 4 + 39, with 7 and 8 columns; 87 rows as 80 + 8); an invoice's two tables come back with the wrong column count (8 x 4 for 5 x 2, 12 x 3 for 12 x 5). Where the shape is right, cell text can still differ. Lists: an Arabic and a Hebrew list come back as one paragraph each (the marker at the right edge is not seen as a marker), and a contract's parties numbered "(1)", "(2)" are joined to the sentence that introduces them.

**Ninth round: boxes side by side, right-to-left lists and tables, long tables; then golden_v10.** Fixed on golden_v9 (now a development set; there text 0.93 -> 0.99, tables 0.62 -> 0.76, lists 0.59 -> 0.85, code 0.63 -> 0.88; golden_v1 to v4 stay at 1.00; v6 tables 0.61 -> 0.68, v7 tables 0.68 -> 0.79 and lists 0.55 -> 0.77, v8 tables 0.67 -> 0.75 and lists 0.83 -> 0.86):
- two boxes side by side, with a title, a date line, a heading or a footer crossing their gutter, are read box by box -- the x where the fewest lines cross (at most a fifth of the ink height) splits the stretches between the crossing lines;
- a CSS-drawn bullet's item joins its next line (the join wanted it indented past a typed marker);
- on a right-to-left page a drawn bullet or a typed marker is looked for at the right, items are joined and levelled by their right edge, a table whose cells are mostly right-to-left lists them rightmost first, and the Arabic letter fix reaches table cells;
- a table over three pages joins its third part to its second, not to its first;
- a cell lying over two cells of one other row (a subtotal label) spans columns and no longer joins their bands; bands join only when spans truly overlap; and the two-columns test places cells as the grid does;
- an indented line of code continues the block under a one-character line (a JSON brace).

Tried and WITHDRAWN on measurement: building a borderless table's rows from overlapping heights instead of baselines (it fixed three tables with vertically centred two-line cells and broke three others, and cost text on v8 and v9). Guard 128 assertions under Ring++.

golden_v10: 24 realistic documents in 15 languages besides English (Persian, Arabic and Hebrew among them, each with lists and tables), 12 of 2-3 pages, side-by-side boxes in 13 of them, by a tenth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (the set is unperceived); reader frozen at 9df81b212; both readers ran once. The scorer is unchanged: Persian zero-width non-joiners are kept on both sides, as in every earlier round.

| golden_v10, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.88** | **1.00** | 0.76 | **0.68** | **0.69** | 0.71 | **1.00** |
| Docling 2.141 | 0.79 | 0.99 | **0.81** | 0.64 | 0.65 | **0.83** | 0.00 |

Time for the 24 documents: native 0.3 s, Docling 654 s. **For the first time on a set of realistic documents (golden_v5 to v10), the native reader leads on tables** (0.68 against 0.64); it also leads on lists (0.69 against 0.65) and takes text back (0.88 against 0.79); Docling leads on headings and furniture. Both readers lose text on this set: it is harder than golden_v9 for both. Causes read off the native output: a Persian page loses its text (0.00) to three faults -- medial heh comes out as U+06BE (the Arabic letter fix is skipped on Persian pages, which do not use that letter either), the zero-width non-joiners are dropped, and the hamza of «همهٔ» comes loose as a separate mark; a title set with wide letter spacing is read with tabs between its words (each gap taken for a cell boundary), and a split initial reads "E lève"; of the 108 furniture lines, 29 are missed, 16 of them at the head of page 1 (letterheads). Round 10.

**Tenth round: Persian, combining marks, tab glyphs, boxes under titles; then golden_v11.** Fixed on golden_v10 (now a development set; there text 0.88 -> 0.90, headings 0.76 -> 0.81, tables 0.68 -> 0.71; golden_v1 to v4 stay at 1.00; v6 text 0.95 -> 0.98, v7 lists 0.77 -> 0.78, v8 headings 0.985 -> 0.993):
- Arabic-Indic and Persian digits read as a number run, left to right (a Persian price came back reversed);
- a combining mark -- hamza, tanween, harakat, Hebrew points, Latin accents -- makes no gap and follows its base letter (never a space or a full stop it overhangs); the hamza of «کتابخانهٔ» split the word and came first;
- outside Urdu, U+06BE (the glyph a font shares with initial and medial heh) is heh, and on a Persian page the digits shared with the Arabic-Indic ones are the Persian ones;
- a glyph that a producer's ToUnicode maps to a TAB or a line end is a space, and one mapped to U+0000 is nothing (titles read "Bulletin<TAB>de<TAB>notes");
- a wide line is a spanning line only if it crosses the narrow units' gutter;
- two key/value boxes side by side read as one table under a row of titles are split, one table per box, each title a heading.

WITHDRAWN on measurement: a short bold label a little smaller than the body read as a heading. The heading score rose (v10 0.81 -> 0.83), but checked against the sets' own headings and table cells, the 30 blocks it newly called headings were 3 expected headings, 18 table header cells and 9 neither. **The shared scorer counts heading RECALL only**, so it rewards false headings; from this round the memo also reports heading precision, computed the same way for both readers and outside the scorer, so the earlier rows stay comparable. Not recovered: the Persian zero-width non-joiner (no glyph, no gap). Guard 138 assertions under Ring++.

golden_v11: 24 realistic documents in 19 languages besides English (Urdu, Persian, Arabic, Hebrew, Amharic, Vietnamese, Russian and Greek among them), 12 of 2-3 pages, by an eleventh independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at 24a58eff4; both readers ran once:

| golden_v11, realistic | text | order | headings | tables | lists | furniture | code |
|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.89** | **1.00** | **0.82** | 0.61 | **0.66** | **0.72** | **0.50** |
| Docling 2.141 | 0.83 | 0.98 | 0.73 | **0.66** | 0.53 | 0.52 | 0.38 |

Heading precision (the share of a reader's heading blocks that are expected headings, pooled over the set):

| heading precision | golden_v9 | golden_v10 | golden_v11 |
|---|---|---|---|
| Softanza native | 0.61 | 0.67 | **0.71** |
| Docling 2.141 | **0.86** | **0.82** | 0.69 |

Time for the 24 documents: native 0.1 s, Docling 148 s. The native reader leads on six of the seven measures; Docling keeps tables (0.66 against 0.61). Heading precision is the measure the shared score did not show: on golden_v9 and v10 four native headings in ten were not headings, against two in ten for Docling; on golden_v11 the two are level.

Causes read off the native output: **code in a proportional face is not code to the native reader** -- r17's four blocks were printed in Segoe UI (the only fonts the PDF embeds, though its CSS asks for a monospaced face) and the reader finds code by a monospaced font only; Docling's layout model finds three of the four by their look. An Urdu page set in a Nastaliq face loses its text for both readers (text 0.00): its letters are drawn as dotless bodies plus separate dots, and the text layer maps the bodies to dotless letters («حامع م حد» for جامع مسجد). The Persian page still loses its zero-width non-joiners. Tables: separate tables merged into one (three of 4, 4 and 7 rows come back as one of 15), one table cut in two (11 rows as 2 + 9; 16 as 3 + 4), wrong column counts (9 for 5). Round 11.

**Eleventh round: heading precision; then golden_v12.** The native reader's false headings were classified over golden_v5 to v11 (1,218 heading blocks, 417 false): 106 letterhead lines, 88 table cells, the rest mostly labels and figures. Fixed, each rule measured for what it costs in true headings before it was kept:
- a heading is never a label ending in a colon or a full stop, nor a figure with no letter (78 false, 1 true -- the run-in "Abstract." of golden_v5, whose guard assertion was changed to the measured decision); a refused run-in lead goes back into its paragraph;
- a heading that shares its baseline with two or more other short blocks is a cell of a row, unless prose follows it (a poster's column headings): about 68 false removed, 3 true lost;
- the micro sign beside a Greek letter is mu (a font draws both with one glyph; golden_v11 text 0.89 -> 0.91).

Heading precision on the development sets, before -> after: v5 0.58 -> 0.65, v6 0.64 -> 0.75, v7 0.70 -> 0.77, v8 0.65 -> 0.73, v9 0.62 -> 0.81, v10 0.69 -> 0.73, v11 0.71 -> 0.79; heading recall moved by at most one heading per set except v7 (0.98 -> 0.96). Tables were not touched this round: two key/value boxes side by side without a title row, merged and then stacked onto the next table, need more than a rule (r09). Guard 143 assertions under Ring++.

golden_v12: 24 realistic documents in 18 languages besides English, 13 of 2-3 pages, by a twelfth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived) -- and who, from this set on, checked that every font it named was installed and embedded (the r17 lesson: its five code blocks are really monospaced); reader frozen at 3df1deb8e; both readers ran once:

| golden_v12, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | 0.89 | **0.99** | **0.89** | 0.61 | **0.63** | **0.62** | **0.89** | **0.86** |
| Docling 2.141 | **0.92** | **0.99** | 0.85 | **0.65** | 0.52 | 0.58 | 0.56 | 0.82 |

Time for the 24 documents: native 0.1 s, Docling 188 s. **The heading-precision work carried over to unseen documents**: native 0.86 against Docling 0.82, where on golden_v9 and v10 it was 0.61-0.67 against 0.82-0.86. Docling leads on text (0.92 against 0.89) and still on tables. Causes read off the native output: an Arabic page in Sakkal Majalla loses most of its text for BOTH readers (native 0.00, Docling 0.17: «على» reads «عال», «بعد» reads «عد») -- the text layer again; a two-column scientific article is read at 0.50 by the native reader and 1.00 by Docling. golden_v12 is now a development set for round 12.

**Twelfth round: tables, lists, columns; then golden_v13.** Fixed on golden_v8 to v12 (v12 became a development set after round 11 was measured on it):
- a header cell set off-centre beside the right-aligned figures it heads is not a column of its own (it made 9 columns for 5); over an empty column it stays -- a looser form fixed two more tables and broke a bank statement (1.00 -> 0.26) and was withdrawn;
- a ruled table ends at its last horizontal rule, so the borderless body of a timetable ruled only in its header is stacked under it;
- a key/value table may have phrases for values (labels of four words or fewer, values of fifteen or fewer, no bullets: a list set in two columns stays a list);
- Arabic-Indic and Persian digits, and bracketed markers -- (a) (iv) (12) [3] -- open list items; the cost: one set's contract clauses numbered "(1)", which its author counts as paragraphs (v9 p03 text 1.00 -> 0.875);
- a low-ink gutter that no line crosses splits two columns, even when a few lines run into the gap (a two-column article was read line by line across both).

On the development sets, start of round -> freeze: lists v5 0.57 -> 0.62, v8 0.86 -> 0.93, v9 0.85 -> 0.92, v10 0.69 -> 0.81, v11 0.66 -> 0.72, v12 0.63 -> 0.78; tables v11 0.61 -> 0.71, v12 0.61 -> 0.67; text v12 0.89 -> 0.91. **The table and list changes made before golden_v12 was opened already moved it** (tables 0.61 -> 0.67, lists 0.63 -> 0.66): the first out-of-sample check inside a round. Guard 153 assertions under Ring++.

golden_v13: 24 realistic documents in 19 languages besides English (Arabic, Persian and Hebrew each with lists and tables), 15 of 2-3 pages, every named font checked as embedded, by a thirteenth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at 671a8cd74; both readers ran once:

| golden_v13, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | 0.88 | **1.00** | **0.90** | **0.68** | **0.75** | **0.75** | **1.00** | **0.83** |
| Docling 2.141 | **0.93** | 0.97 | 0.89 | 0.66 | 0.56 | 0.74 | 0.50 | 0.81 |

Time for the 24 documents: native 0.1 s, Docling 153 s. **On unseen documents the native reader now leads on everything but text** -- tables included (0.68 against 0.66) and heading precision (0.83 against 0.81). The text gap (0.88 against 0.93) is mostly two documents: an electricity bill whose boxes side by side are still read line by line across both (native 0.25, Docling 1.00), and an Arabic school-results sheet (native 0.40, Docling 0.80); a Persian page set in a Nastaliq face loses its text for both readers (0.00 and 0.14), the text layer once more. Round 13.

**Thirteenth round: reading order of boxes, letterheads, a kerned alef; then golden_v14.** Fixed on golden_v13 (now a development set) and checked on golden_v1 to v13:
- with no gutter, the XY cut splits a region at its widest horizontal gap instead of peeling one strip from the top, so a band of boxes side by side between two full-width tables becomes a region of its own and finds its gutter (an electricity bill's text 0.25 -> 1.00);
- address lines read together as one block are still a letterhead (up to four lines of eight words or fewer, no sentence's full stop), and a margin block of up to three short lines in type up to 0.92 of the body is furniture;
- a right-to-left line is ordered by each glyph's right edge, where the pen set it: a kerned alef tucked into a ra's tail has its origin right of the ra's, and «الدراسية» read «الدارسية» (an Arabic sheet's text 0.40 -> 0.80).

On the development sets, round-12 freeze -> round-13 freeze: text v5 0.93 -> 0.97, v10 0.90 -> 0.91, v13 0.88 -> 0.94; furniture v6 0.72 -> 0.80, v8 0.58 -> 0.61, v11 0.72 -> 0.76, v13 0.75 -> 0.77; v5 order 0.97 -> 1.00; lists v13 0.75 -> 0.79. Costs: v6 text 0.975 -> 0.967 (a side box cut by a gap only one column has) and the furniture of three documents. Guard 158 assertions under Ring++.

golden_v14: 24 realistic documents in 18 languages besides English, 13 of 2-3 pages, every named font checked as embedded, by a fourteenth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at 4dc2e0b56; both readers ran once:

| golden_v14, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.94** | **1.00** | 0.86 | 0.67 | 0.38 | **0.87** | **1.00** | **0.81** |
| Docling 2.141 | 0.89 | 0.99 | 0.86 | **0.68** | 0.38 | 0.84 | 0.33 | 0.79 |

Time for the 24 documents: native 0.1 s, Docling 131 s. **The native reader takes text back on unseen documents** (0.94 against 0.89, where golden_v13 had 0.88 against 0.93) and leads on order, furniture, code and heading precision; headings, tables and lists are level. Lists are low for BOTH readers for one reason: this set TYPES its markers into the text ("• ", "– ", "1. ", "α) "), set apart from the item by a hanging indent, and its expected items keep them; the native reader drops a marker that stands apart from its item. A bullet glyph standing apart can only be typed -- Chrome draws CSS bullets as shapes -- so it can be kept; a number standing apart cannot be told from a CSS-numbered list, which Chrome also writes as text. Round 14.

**Fourteenth round: typed markers; then golden_v15.** Fixed on golden_v14 (now a development set):
- a marker set apart from its item by a hanging indent is text the producer wrote, so it stays at the head of the item -- bullet glyphs (Chrome draws CSS bullets as shapes, so a glyph was typed) and numbers too: the expected ambiguity with CSS-numbered lists was MEASURED before deciding, and over golden_v1 to v13 no CSS-numbered list ever left its number standing apart (keeping numbers moved no earlier set). golden_v14 lists 0.38 -> 0.50 with glyphs, -> 0.73 with numbers;
- a table of short cells whose last column holds descriptions (rows of two to four cells, the last up to fifteen words) is a table (v12 tables 0.671 -> 0.685).

Not recovered, and now measured: on golden_v14's Persian page every key sentence matches once the zero-width non-joiner is removed, so the whole gap between its text score (0.17) and 1.00 is that one invisible character, which leaves no glyph and no gap. The scorer keeps it, as in every round, so the series stays comparable. Guard 161 assertions under Ring++.

golden_v15: 24 realistic documents in 19 languages besides English, 14 of 2-3 pages, every named font checked as embedded and every character checked against its font, by a fifteenth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at 2280d83c5; both readers ran once:

| golden_v15, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.94** | **1.00** | 0.81 | 0.72 | **0.84** | **0.82** | **1.00** | **0.86** |
| Docling 2.141 | 0.88 | 0.98 | **0.90** | **0.74** | 0.50 | 0.75 | 0.00 | 0.79 |

Time for the 24 documents: native 0.1 s, Docling 159 s. The native reader leads on six of the eight measures, lists by a wide margin (0.84 against 0.50); Docling leads on headings (0.90 against 0.81) and narrowly on tables. One cause read off the output, and Docling shows it is recoverable: a Greek page set in Cambria loses its accents in the native reader (text 0.00 -- «ιστορικο» for «ιστορικό») because Chrome's ToUnicode maps the separate tonos glyph to U+0000, which the reader drops; Docling reads the same page at 1.00, so the accent is in the file (the embedded font's own cmap is the likely source). Round 15.

**Fifteenth round: marked content's ActualText; then golden_v16.** The Greek page of golden_v15 that Docling read at 1.00 and the native reader at 0.00 led to one cause, and it was bigger than that page: Chrome wraps every glyph cluster its ToUnicode cannot name in marked content carrying an /ActualText -- a Greek letter drawn as a base glyph plus an accent glyph mapped to U+0000, a Nastaliq cluster, a Sakkal Majalla ligature, a Persian word with its zero-width non-joiner. 198 such spans on that one page. The reader ignored them. It now honours them (BDC/BMC/EMC): the span's glyphs become one glyph over their width reading as the ActualText (UTF-16 with its byte-order mark, or PDFDocEncoding). Three side effects were found on the earlier sets and fixed before keeping it: soft hyphens arrive as ActualText (stripped: they are invisible break points), a hyphen at a line end arrives as U+2010 (now joined like '-'), and an ActualText bracket is already logical (no longer mirrored on a right-to-left line).

On the development sets: text v10 0.91 -> 0.94, v11 0.91 -> 0.94, v12 0.91 -> 0.96, v13 0.94 -> 0.98, v14 0.94 -> 0.98, v15 0.94 -> 0.98; the Nastaliq Persian page 0.00 -> 1.00, three other Persian pages 0.17-0.25 -> 1.00 (the zero-width non-joiner was in the ActualText all along -- the "not recoverable" of rounds 10 to 14 was wrong), the Greek page 0.00 -> 1.00, the Sakkal Majalla page 0.00 -> 0.50; golden_v1 to v4 stay at 1.00. Still lost, by both readers: an Urdu Nastaliq page whose missing glyphs lie outside any marked span. Guard 166 assertions under Ring++.

golden_v16: 24 realistic documents in 21 languages besides English, accented scripts well represented on purpose (Greek, Vietnamese, French, Portuguese, Czech, Polish, Romanian, Hungarian, Turkish, Yoruba) with Arabic, Persian and Hebrew, 12 of 2-3 pages, every named font and character checked against the embedded fonts, by a sixteenth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at b955c191b; both readers ran once:

| golden_v16, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.98** | **1.00** | 0.85 | **0.80** | **0.91** | 0.68 | **1.00** | **0.92** |
| Docling 2.141 | 0.83 | 0.99 | **0.86** | 0.74 | 0.44 | **0.69** | 0.33 | 0.79 |

Time for the 24 documents: native 0.1 s, Docling 142 s. **The widest lead in the series**: text 0.98 against 0.83, tables 0.80 against 0.74, lists 0.91 against 0.44, heading precision 0.92 against 0.79; Docling stays ahead by a hair on headings (0.86 against 0.85) and furniture (0.69 against 0.68). Of the native reader's 24 missed furniture lines out of 105, 8 are letterheads; most of the rest are page numbers written in the document's own language on one-page documents («Σελίδα 1 από 1», «1/1. oldal»), which do not repeat and which the page-number test does not know. Round 16.

**Sixteenth round: page numbers in any language, headings above tables; then golden_v17.** Fixed on golden_v16 (now a development set):
- a page number in any language, with no word list: one or two small numbers (a page and a count apart by a word or a slash, the count not below the page), at most three words, the usual separators, one number coming last or alone ("Seite 3", «Σελίδα 1 από 1», «1/1. oldal», Arabic-script digits); never larger than the body ("AquaSense 300" at the top of a page is a title -- the first form took it, and was narrowed before keeping); a number first then words, or "1.2", is a numbered heading -- the first form also took those, and lowered headings on twelve sets before it was narrowed;
- when the lowest line of a page holds a page number, that line and the blocks on its baseline are the page's footer wherever it sits (footers set inside the page box, above the bottom band);
- a heading above a table becomes its caption only when it names itself with a number (65 of the 84 captions in the sets hold a digit).

On the development sets, round-15 freeze -> round-16 freeze: furniture v16 0.68 -> 0.75, v12 0.63 -> 0.65, v13 0.76 -> 0.77; headings v11 0.845 -> 0.851, v14 0.868 -> 0.878; nothing falls. Guard 170 assertions under Ring++.

golden_v17: 24 realistic documents in 17 languages besides English across nine scripts (Latin, Greek, Cyrillic, Arabic, Hebrew, Ethiopic, Devanagari, Thai, Japanese), 14 of 2-3 pages, page numbers in each document's own language, every named font and character checked against the embedded fonts, by a seventeenth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at 783ebf23b; both readers ran once:

| golden_v17, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.93** | **1.00** | **0.89** | **0.73** | **0.87** | **0.87** | **1.00** | **0.82** |
| Docling 2.141 | 0.84 | 0.99 | 0.85 | 0.71 | 0.58 | 0.73 | 0.13 | 0.75 |

Time for the 24 documents: native 0.1 s, Docling 531 s. **For the first time the native reader leads on every one of the eight measures.** Its two weakest documents are new scripts: a Hindi voter guide (text 0.20; Docling 0.00) whose sentences run into a neighbouring block, and a Japanese permit (text 0.60; Docling 0.60) where a space is inserted where a line wraps inside a sentence -- Japanese writes no spaces between words, so a wrapped line must join with none. Round 17.

**Seventeenth round: scripts without spaces, Devanagari clusters; then golden_v18.** Fixed on golden_v17 (now a development set):
- scripts written without spaces between words (Japanese, Chinese, Thai, Lao, Khmer, Myanmar, CJK full-width forms) join a wrapped line with no space, and inside a line a gap between two such glyphs is a space only when it is wide (a Japanese permit 0.60 -> 1.00, a Thai plan 0.75 -> 1.00);
- a marked span counts every glyph drawn inside it, with or without text of its own, and builds its glyph from that extent even when none had text: a Devanagari conjunct whose glyphs all had an empty ToUnicode vanished, and a cluster of zero width left a gap that cut a word in two;
- Indic combining signs (Devanagari to Malayalam) and Thai vowel and tone marks are marks: no word gap is measured from them.

The Hindi voter guide: text 0.20 -> 0.80, tables 0.08 -> 0.97, headings 0.63 -> 1.00; v17 text 0.93 -> 0.98, tables 0.73 -> 0.76; nothing falls on golden_v1 to v17. Guard 173 assertions under Ring++.

golden_v18: 24 realistic documents in 17 languages besides English (Chinese, Japanese, Korean, Hindi, Thai, Arabic and Hebrew among them), 13 of 2-3 pages, every named font and character checked against the embedded fonts, by an eighteenth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at 7368f93a3; both readers ran once:

| golden_v18, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.96** | **1.00** | **0.86** | 0.69 | **0.87** | **0.88** | **1.00** | **0.80** |
| Docling 2.141 | 0.80 | 0.98 | 0.82 | **0.73** | 0.51 | 0.77 | 0.00 | 0.75 |

Time for the 24 documents: native 0.1 s, Docling 395 s. The native reader leads on seven of the eight measures; Docling on tables (0.73 against 0.69), which is where the native reader's work now is. Its weakest text is a Japanese hotel page (0.43; Docling 0.29) whose two shaded boxes side by side are read line by line across both. Round 18.

**Eighteenth round: tables; then golden_v19.** Tables were the one measure Docling still led on unseen documents. Fixed on golden_v15 to v18 and checked on all eighteen sets:
- two tables read as one are split: columns falling into a left and a right group that no row fills both of (section rows set aside) are two tables side by side, and a row repeating the header row starts a table of its own (an athletics results page 0.37 -> 0.82);
- a body cell of two lines beside cells of one, centred in their row (the CSS default), makes three baseline rows that are ONE table row (not for bold header cells: merged there, a header joined the table above it);
- a line with a bullet drawn before it is a list item, never a table cell.

Withdrawn again on measurement: grouping rows by overlapping heights in general (it chained rows that are not one row). On the development sets: tables v7 0.79 -> 0.81, v8 0.75 -> 0.79, v9 0.77 -> 0.79, v10 0.72 -> 0.77, v15 0.74 -> 0.76; lists v8 0.94 -> 0.98, v10 0.83 -> 0.90. Costs: text v9 0.981 -> 0.975, v10 0.944 -> 0.930, v18 0.964 -> 0.957, and v18 lists 0.87 -> 0.83 -- a table now grows across into a list in the box beside it; and one table absorbs a column of prose from the next text column, which the table score (expected cells in place) does not see. Guard 177 assertions under Ring++.

golden_v19: a TABLE-RICH set -- 24 realistic documents, every one with at least one table and 20 with two or more, in every style (ruled, partly ruled, zebra, borderless, two-level headers, merged cells, totals, two-line cells, tables across pages) -- in 16 languages besides English, 15 of 2-3 pages, every named font and character checked against the embedded fonts, by a nineteenth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at f278bbfea; both readers ran once:

| golden_v19, table-rich | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.99** | **1.00** | **0.91** | **0.69** | **0.86** | **0.90** | **1.00** | **0.90** |
| Docling 2.141 | 0.87 | 0.98 | 0.80 | 0.67 | 0.55 | 0.89 | 0.00 | 0.71 |

Time for the 24 documents: native 0.1 s, Docling 738 s. **On a set built to stress tables, the native reader leads on all eight measures, tables included (0.69 against 0.67).** Tables are still the measure with the most room for both readers. Causes read off the native output: one row too many in three tables -- the second line of a wrapped cell read as a row of its own (a description, a two-line header, an amount under its value), the case the centred-cell rule does not cover because these cells are top-aligned, side-by-side tables whose rows fill both halves still read as one wide table, and two tables not found.

**Nineteenth round: tables again; then golden_v20.** Fixed on golden_v19 (now a development set) and checked on all nineteen sets:
- the second line of top-aligned wrapped cells, set at line pitch under its row where the run's rows are set further apart, joins the row above cell by cell -- only when its first column is empty, not under a cell spanning two columns and not under the run's header row; without those guards it broke a two-level header (0.72 -> 0.50), which was measured before deciding;
- a table whose header row is the same header twice is two tables side by side, even when every row fills both halves.

On the development sets: tables v8 0.79 -> 0.81, v9 0.794 -> 0.796, v10 0.768 -> 0.772, v19 0.691 -> 0.694 (side-by-side results 0.60 -> 0.67), a council-results table 0.45 -> 0.91, a price list 0.50 -> 0.65; cost: one table on v12 0.82 -> 0.77. Not reached this round: golden_v19's own three tables with a wrapped line read as a row did not move; why the new rule does not apply to them is not yet found. Guard 181 assertions under Ring++.

golden_v20: 24 realistic documents in 17 languages besides English (Chinese, Japanese, Korean, Thai, Hindi, Arabic and Hebrew among them), 12 of 2-3 pages, cells of two and three lines top-aligned as well as centred, every named font and character checked against the embedded fonts, by a twentieth independent agent who saw no reader, no output and no earlier set and did not look at the rendered pages (unperceived); reader frozen at c5211db15; both readers ran once:

| golden_v20, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.92** | 1.00 | **0.85** | 0.67 | **0.53** | **0.79** | 0.83 | **0.76** |
| Docling 2.141 | 0.77 | 1.00 | 0.81 | **0.68** | 0.44 | 0.72 | 0.83 | 0.68 |

Time for the 24 documents: native 0.1 s, Docling 437 s. The native reader leads on five measures, ties on order and code, and Docling leads on tables by a hair (0.678 against 0.671). Lists are low for BOTH readers, and the cause is read off the output: this set types list markers in many conventions -- "1.1", "（1）", "（一）", "※", "(क)", "1-", "1.ª", "א." -- that the native reader does not know, and where such markers stand apart from their text, the marker column and the text column are taken for a two-column table. Round 20.

**Twentieth round: list markers in many conventions; then golden_v21.** Fixed on golden_v20 (now a development set) and checked on all twenty sets:
- list markers in the conventions documents in many languages use: multi-level decimals ("1.1", "2.3.4" -- never a figure like "850.00": the first form read a budget table's amounts as markers and dissolved it, and was guarded before keeping), "1-", Spanish ordinals, full-width CJK "（1）"/"（一）", reference and shape bullets, a letter of any non-Latin script in brackets "(क)", a single non-Latin letter then "." or ")" ("א.", "б)");
- a standing-apart marker joins only a fragment that starts with a word, never a figure;
- a first column of list markers beside running text is a list, not a two-column table;
- an italic numbered line is a heading, as an italic plain line is.

On the development sets, lists: v20 0.53 -> 0.79, v6 0.74 -> 0.94, v10 0.90 -> 0.97, v17 0.87 -> 0.96, v19 0.86 -> 0.92, v14 0.75 -> 0.81, v12 0.82 -> 0.86, v5 0.63 -> 0.69, many documents 0 -> 1.00; headings v20 0.865 -> 0.875; golden_v1 to v4 stay at 1.00. Costs: text on three documents (0.99 -> 0.87, 1.00 -> 0.85, 1.00 -> 0.84) and a little on four tables. Guard 186 assertions under Ring++.

golden_v21: 24 realistic documents in 19 languages besides English (Persian, Thai, Vietnamese, Hebrew and Arabic among them), 17 of 2-3 pages, three right-to-left documents with lists and tables, ten with side-by-side boxes read box by box, three with code; written by two independent agents who saw no reader, no output and no earlier set -- the first stopped after d18 on an API error, the second wrote d19-d24 and the README reading only d01-d18 of this set; the second looked at screenshots of its own HTML pages, never of the PDFs; no person has looked at the pages (unperceived); reader frozen at 66ec5c544 (5d1638458 before the rebase); both readers ran once:

| golden_v21, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.96** | **1.00** | **0.89** | **0.82** | **0.76** | **0.91** | **1.00** | **0.90** |
| Docling 2.141 | 0.78 | 0.99 | 0.88 | 0.73 | 0.50 | 0.88 | 0.39 | 0.82 |

Time for the 24 documents: native 0.09 s, Docling 107 s. The native reader leads on all eight measures, the third set where it does (after golden_v17 and golden_v19); lists, the round's subject, lead by 0.26. Where Docling does better, document by document: tables on seven documents (a table read as nothing on d11, 0.27 against 0.59 on d22, 0.62 against 0.95 on d24), lists on four (d05 and d17 find no list item where Docling finds three in four), headings on three. The worst native document is d21, Thai: text 0.50, no heading and no list item found. On d19, Persian, two of seven sentences are missed; the zero-width non-joiners are not the cause -- the native output keeps them as the source has them. Causes on d21, d05, d17 and the tables not yet looked into: round 21.

**Twenty-first round: scripts, CJK markers, tables ruled between their rows; then golden_v22.** Fixed on golden_v21 (now a development set) and checked on all twenty-one sets:
- the letter test behind every heading stopped at Sinhala, so a Thai, Lao, Khmer, Myanmar, Georgian or Armenian heading was refused as a figure; list markers in the decimal digits of any script ("๑.", "१.");
- CJK markers: full-width "１．", "（１）" standing apart (a marker of more than six bytes was never joined), circled "①", "一、" and "イ、"; a marker column's text counts its words by characters in scripts without spaces; a CJK marker set apart by a visible gap is followed by a space, one set close ("（1）網口") stays as written -- a space after every CJK marker was tried first and cost v17's lists and the spelling of Chinese headings;
- a table ruled only between its rows -- a ladder of four or more horizontal rules of one width, each row's rule often drawn as one segment per cell -- is a table whose rows are the gaps between rules, so a cell of two lines or a cell centred across two columns stays in its row; a band of one bold or larger cell is a heading and breaks the ladder; a heading set larger than two tables' cells is never stacked into them as a section row; a header of two rows repeated on the next page is dropped whole;
- a group label centred over some columns just above a header ("Wymagania" over "min." and "maks.") makes a two-row header -- a label is a few words inside the table, centred on its own columns and not on the table: the first form took centred and edge captions on 19 sets.

Tried and withdrawn: a ladder replacing a table found earlier without lines inside it -- tables fell on 15 sets (v4 1.00 -> 0.75), because a ladder band missing a rule holds two rows where the aligned finder reads the lines.

On the development sets: tables v21 0.82 -> 0.92, v20 0.67 -> 0.77, v14 0.67 -> 0.77, v7 0.81 -> 0.91, v15 0.76 -> 0.82, v16 0.80 -> 0.85, rising on fourteen sets; lists v21 0.76 -> 0.92, v20 0.79 -> 0.84; headings v19 0.91 -> 0.96, v20 0.88 -> 0.93, v21 0.89 -> 0.93, v17 0.90 -> 0.94; nothing fell but v20 heading precision 0.770 -> 0.767. Not reached: d21's list column beside a column of advice is still read as a table, and d19 (Persian) loses or reorders a word at two line wraps. Guard 195 assertions under Ring++ (one round-20 assertion updated to the expected text "（1） 平日", which the reader now gives).

golden_v22: 24 realistic documents in 17 languages besides English (Arabic, Hebrew and Persian right to left, Japanese, Chinese, Korean, Hindi, Thai among them), 13 of 2-3 pages, tables drawn in many styles (full grids, rules between rows only, rules under the header only, zebra bands, boxed panels, no lines) and lists set beside other columns, by a twenty-second independent agent who saw no reader, no output and no earlier set; no one has looked at the pages (unperceived); reader frozen at 2c55ed1f4; both readers ran once:

| golden_v22, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.97** | 1.00 | **0.94** | **0.85** | **0.89** | **0.86** | **1.00** | **0.87** |
| Docling 2.141 | 0.85 | 1.00 | 0.82 | 0.66 | 0.48 | 0.74 | 0.50 | 0.70 |

Time for the 24 documents: native 0.1 s, Docling 169 s. The native reader leads on seven measures and ties on order; tables lead by 0.19 and lists by 0.41. Where Docling does better, document by document: tables on five (e10 nothing against 0.54, e11 0.03 against 0.62, e13 0.38 against 1.00), furniture on three (e14 0.25 against 1.00), lists on two (e17, Korean, 0.40 against 0.60), headings and text on one each. Causes not yet looked into: round 22.

**Twenty-second round: zebra tables, letterheads over a smaller title, markers in a document's own letters; then golden_v23.** Fixed on golden_v22 (now a development set) and checked on all twenty-two sets:
- the interpreter keeps filled rectangles shaped like a table row (not white), and the edges of the shaded bands of a zebra table are row rules for the ladder -- a band only in a run of bands of one width holding a row's cells (two columns or more, no code), a one-cell section band beside such a run; the last, unshaded row is taken below the last edge; a table found earlier that runs across the ladder's edge (a timetable read together with the sidebar beside it) gives way unless its header is the same header twice, and only the text it releases is read again; a tall band whose top line is a lone bold line at the table's edge holds the next table's heading and breaks the ladder. Refined on the way: a code block's grey box and a callout joined a ladder (k14), shaded result headings chained several tables into one (x22);
- a letter-spaced CJK title ("采 购 订 单", half an em apart) is one phrase; an organisation's name at the very top set larger than the title, over short lines holding five digits running (a postcode, a telephone, a registration number), is a letterhead and the next heading down is the title -- any digit took a dated byline for an address (headings fell on 18 sets), eight digits took a validity line of two dates;
- list markers in a document's own letters: Thai "ก.", Korean "가.", kana "ア)"; a katakana marker standing apart only in the a-i-u-e-o and i-ro-ha orders (any katakana split the letter-spaced title "ダ イ ヤ").

On the development sets: golden_v22 tables 0.85 -> 0.90, lists 0.89 -> 0.94, furniture 0.86 -> 0.91; tables v14 0.77 -> 0.86, v9 0.81 -> 0.89, v10 0.79 -> 0.82, v21 0.92 -> 0.95; furniture v7 0.54 -> 0.62; lists v19 0.96 -> 0.98. Costs: heading precision v12 0.849 -> 0.827, v6 0.784 -> 0.772; tables v12 -0.003. Not reached: e06's page numbers "1" and "2" can never be kept out of a body that holds those digits (a limit of the measure, not of either reader); e05's author writes a CJK marker with no space where the page shows a gap, which the reader keeps. Guard 206 assertions under Ring++.

golden_v23: 24 realistic documents in 17 languages besides English (Arabic, Hebrew and Persian right to left, Japanese, Chinese, Korean, Hindi, Thai among them), 12 of 2-3 pages, forms and official letters with letterheads, pages mixing columns, sidebars and boxes, by a twenty-third independent agent (which shared f07-f24 among three helpers working under the same brief) who saw no reader, no output and no earlier set; no one has looked at the pages (unperceived); reader frozen at c3c23b0aa; both readers ran once:

| golden_v23, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.96** | **1.00** | **0.95** | **0.79** | **0.86** | **0.81** | **1.00** | **0.82** |
| Docling 2.141 | 0.82 | 0.99 | 0.79 | 0.67 | 0.50 | 0.78 | 0.25 | 0.69 |

Time for the 24 documents: native 0.06 s, Docling 169 s. The native reader leads on all eight measures, the fourth set where it does. Where Docling does better, document by document: tables on seven (f15, a balance sheet across pages, 0.04 against 0.58; f01, a tax invoice, 0.13 against 0.68; f23, a bilingual notice, nothing against 0.80), furniture on five (f12 0.20 against 1.00, f22 0.40 against 1.00 -- letterheads), lists on three (f05 nothing against 0.43), text on two and headings on one (f23 again). Causes not yet looked into: round 23.

**Twenty-third round: column rules, tall rows, ladders kept whole, letterheads beside the title; then golden_v24.** Fixed on golden_v23 (now a development set) and checked on all twenty-three sets:
- a tall vertical rule with text close on both sides separates two columns: the text beside it is read for tables one side at a time, everything else held out of each reading (f23's English and French columns had paired their wrapped list lines into a table);
- several two-line cells beside one-line cells centred between them are one row where the shape repeats over the neighbouring lines (one coincidence merged n06's letterhead into a table before the repetition was required); a ladder whose rows are mostly tall cells beside short ones, or a clean ladder (no band that could be two rows merged by a missing rule) holding more rows than the table read inside it, takes that table's place -- all or nothing: a partial dissolve broke k01's and p16's tables on the way;
- a lone bold band of the cells' size at the rows' spacing is a section row ("ATIVO"), and a lone bold label with the rest of its row empty fills the row ("Hemogram" -- found by the guard when a clean ladder took h18's table);
- a block beside the title in the top band, smaller than it, is letterhead; a name larger than the title is a letterhead over an e-mail or web address too ("0510-2440 718" holds no five-digit run); the katakana middle dot "・" is a typed bullet.

On the development sets, against round 22 frozen: every measure rose or held on all twenty-two earlier sets -- tables v15 0.82 -> 0.89, v19 0.72 -> 0.79, v11 0.73 -> 0.79, v14 0.86 -> 0.90, v8 0.81 -> 0.84; furniture v7 0.62 -> 0.73, v8 0.65 -> 0.71, v12 0.65 -> 0.70; heading precision up on twelve sets; golden_v23 text 0.96 -> 0.98, tables 0.79 -> 0.84, lists 0.86 -> 0.93, furniture 0.81 -> 0.86. Not reached: f15's sub-section rows carry no rule, so a ladder band holds two rows and its table still starts late; f01's invoice table. Guard 212 assertions under Ring++.

golden_v24: 24 realistic documents in 18 languages besides English (Arabic, Hebrew and Persian right to left, Japanese, Chinese, Korean, Hindi, Thai, Vietnamese among them), 14 of 2-3 pages, forms, statements, letters and mixed layouts, by a twenty-fourth independent agent who saw no reader, no output and no earlier set; no one has looked at the pages (unperceived); reader frozen at d54b177e4; both readers ran once:

| golden_v24, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.94** | **1.00** | **0.93** | 0.65 | **0.92** | **0.79** | **0.83** | **0.79** |
| Docling 2.141 | 0.72 | 0.99 | 0.83 | **0.66** | 0.43 | 0.73 | 0.17 | 0.71 |

Time for the 24 documents: native 0.06 s, Docling 107 s. The native reader leads on seven measures and Docling on tables, by 0.008. The tables are this set's lesson: the native reader finds NO table on five documents where Docling finds most of one -- g14 (Korean notice, 0.83), g19 (two-column conference paper, 1.00), g21 (Swahili minutes, 0.94), g23 (Portuguese inspection report, 0.85) -- and little on g01 (invoice, 0.14 against 0.52) and g22 (landscape purchase order, 0.03 against 0.32). Furniture on five documents (g13 0.50 against 1.00, g22 nothing against 0.50) and lists on two. Causes not yet looked into: round 24.

**Twenty-fourth round: tables beside narrow paragraphs, spanning cells, wrapped cells; then golden_v25.** Fixed on golden_v24 (now a development set) and checked on all twenty-four sets:
- a line is prose when it belongs to a narrow paragraph -- three lines or more of five words or more one under the other, at a paragraph's leading, running on from line to line, a first line indented allowed -- so a key/value table floated beside a column of six-to-eight-word lines is no longer swallowed by it (g21: no table -> both). Without the leading and running-on conditions a table's description column counted as prose (v6 tables .728 -> .665);
- the key/value test reads each row left to right (a label in another face sits a point off its value's baseline); sorting the rows themselves moved two other documents;
- a cell spanning two rows, centred between them, is in both rows -- only a short first-column label between two rows of the same shape (lone lines were pulled into rows on eight sets before);
- the second line of a top-aligned cell (an invoice item's description under its title) stays in its table's run (g01's items table, never found before).

On the development sets, against round 23 frozen: golden_v24 tables 0.65 -> 0.77 (Docling 0.66); tables v13 0.77 -> 0.82, v18 0.76 -> 0.80, v19 0.79 -> 0.82, v23 0.83 -> 0.85; heading precision up on eight sets. Costs: tables v10 0.831 -> 0.826 (a last row's second line, q17), furniture v13 0.781 -> 0.775, headings v17 -0.004. Not reached: g19's table in a two-column paper has its rows now but not its columns (sensor name and unit cost in one cell); g22, a landscape purchase order. Guard 217 assertions under Ring++.

golden_v25: 24 realistic documents in 16 languages besides English (Arabic, Hebrew and Persian right to left, Japanese, Chinese, Korean, Hindi, Thai, Vietnamese among them), 11 of 2-3 pages, cells spanning rows, forms, reports, letters, running headers drawn by CSS page-margin boxes in four documents, by a twenty-fifth independent agent who saw no reader, no output and no earlier set; no one has looked at the pages (unperceived); reader frozen at aacf66596; both readers ran once:

| golden_v25, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.97** | 0.99 | **0.92** | **0.84** | **0.82** | 0.79 | **0.75** | **0.72** |
| Docling 2.141 | 0.82 | **1.00** | 0.79 | 0.66 | 0.52 | **0.81** | 0.00 | 0.64 |

Time for the 24 documents: native 0.09 s, Docling 84 s. The native reader leads on six measures, Docling on order (by 0.008: h07, Hebrew, 0.80 against 1.00) and on furniture (by 0.021: seven documents, h17 nothing against 1.00 -- a landscape page whose running header is a CSS margin box). Elsewhere Docling does better on tables on five documents (h09 0.10 against 0.55, h23 0.34 against 0.73), lists on three, text on two, headings on one (h04, Arabic, 0.20 against 1.00). Heading precision is the lowest of recent sets for both readers (0.72 and 0.64). Causes not yet looked into: round 25.

**Twenty-fifth round: Arabic headings and markers, foot lines, Demi faces; then golden_v26.** Begun only after round 24 was measured on golden_v25 (the author's ruling: a round's fixes wait for its predecessor's golden measurement). Fixed on golden_v25 (now a development set) and checked on all twenty-five sets:
- a short bold Arabic line at 0.85 of the body is a heading (an Arabic heading's face can look larger at a smaller size: 14 pt over 16 pt) -- Arabic script only, as Hebrew month labels and box titles came in with it; a caption's number may be in any script's digits ("جدول ١");
- "أ-" (a letter and a dash) is a list marker;
- one small line at the very foot of the page is its footer however long (h17, thirteen words, a CSS margin box);
- a Demi face is bold (FranklinGothic-Demi section titles at 10.5 pt over a 9.6 pt body);
- zebra bands in a run may stand two bands apart (an unshaded row of two lines between them).

On the development sets, against round 24 frozen: headings v14 0.88 -> 0.92, v15 0.84 -> 0.88, v16 0.88 -> 0.93, v19 0.96 -> 0.99, v20 0.93 -> 0.95; golden_v25 headings 0.92 -> 0.99, furniture 0.79 -> 0.83, lists 0.82 -> 0.83. Costs: heading precision v21 0.915 -> 0.905, v23 0.833 -> 0.825, v8 -0.004. Tried and withdrawn: one row's slack at a ladder's foot (v9 -0.008). Not reached: h09's movements table -- its debit and credit columns are never filled in the same row, so no body row shows all six columns and the ladder cannot find them; h07's reading order (Hebrew). Guard 223 assertions under Ring++.

golden_v26: 24 realistic documents in 16 languages besides English (Arabic, Hebrew and Persian right to left, Japanese, Chinese, Korean, Hindi, Vietnamese among them), 14 of 2-3 pages, four tables across pages, one landscape page, a bold synthesised by Chrome from a regular face (k03), by a twenty-sixth independent agent who saw no reader, no output and no earlier set; no one has looked at the pages (unperceived); reader frozen at d084effba; both readers ran once:

| golden_v26, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.93** | **1.00** | **0.91** | **0.80** | **0.76** | **0.87** | **0.75** | **0.77** |
| Docling 2.141 | 0.77 | 0.98 | 0.84 | 0.68 | 0.42 | 0.83 | 0.00 | 0.70 |

Time for the 24 documents: native 0.09 s, Docling 93 s. The native reader leads on all eight measures, the fifth set where it does. Where Docling does better, document by document: tables on five (k06, a bank statement across pages, 0.02 against 0.72; k16, landscape lab report, 0.31 against 0.96; k13 0.29 against 1.00; k21 0.50 against 0.96), headings on four (k03 0.17 against 1.00 -- its headings' bold is synthesised by the browser, drawn as fill-and-stroke from a regular face), furniture on five, text on four, lists on three. Causes not yet looked into: round 26.

**Twenty-sixth round: a browser's synthetic bold, letterhead names, columns from the header; then golden_v27.** Fixed on golden_v26 (now a development set) and checked on all twenty-six sets:
- Chrome draws a face it has no bold for as Type3 outlines whose descriptor still names the regular face at weight 400: such a Type3 font is bold when the page also carries that face from its real font file. A variable font drawn entirely as Type3 (Bahnschrift) has no twin and keeps the weight its name says -- marking every named Type3 bold made r18's body bold on the way. This synthetic bold was behind many sets: headings and furniture rose across twenty;
- with those bold names now seen, a short bold name above the title and smaller than it is letterhead -- above only, a sidebar heading beside the title stays a heading;
- a ladder whose body rows never fill every column (a statement's debit and credit) takes its columns from the header row, each widened to the body cells centred in it.

Tried and withdrawn: no growth for a table drawn as a full grid (k16's key/value line above its grid) -- tables fell on six sets (v9 0.893 -> 0.829), headers outside the rules need it.

On the development sets, against round 25 frozen: golden_v26 headings 0.91 -> 0.94, tables 0.80 -> 0.82, lists 0.76 -> 0.79, furniture 0.87 -> 0.91; furniture up on twenty sets (v15 0.85 -> 0.89, v12 0.70 -> 0.75, v9 0.65 -> 0.69, v23 0.85 -> 0.89); headings v9 0.97 -> 1.00, v10 0.86 -> 0.90, v5 0.83 -> 0.86; heading precision up on twenty-one sets. Cost: headings v6 0.984 -> 0.959 (k09's largest heading is "Rx", taken for the title, so the real title above it reads as a letterhead name). Not reached: k16 (a line above a grid table taken as its first row), h09 (its ladder still gives way). Guard 229 assertions under Ring++.

golden_v27: 24 realistic documents in 14 languages besides English (ten scripts: Arabic and Hebrew right to left, Japanese, Chinese, Korean, Hindi, Thai, Greek, Russian among them), 16 of 2-3 pages, by a twenty-seventh independent agent who saw no reader, no output and no earlier set; the agent was stopped by a network error after finishing all 24 documents, and a second agent wrote only the set's README from its own files; no one has looked at the pages (unperceived); reader frozen at ddeedc18c; both readers ran once:

| golden_v27, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.96** | 0.99 | **0.85** | **0.75** | **0.87** | **0.79** | **1.00** | **0.77** |
| Docling 2.141 | 0.73 | **1.00** | 0.72 | 0.69 | 0.47 | 0.74 | 0.00 | 0.64 |

Time for the 24 documents: native 0.08 s, Docling 102 s. The native reader leads on seven measures, Docling on order by 0.008 (m24, 0.80 against 1.00). Where Docling does better, document by document: tables on six (m01 0.02 against 0.88, m21 nothing against 0.97, m06 0.34 against 0.93, m18, m07, m16), furniture on three (m14 0.20 against 0.60), lists on two, headings on one (m08). Headings are this set's weak measure for both readers (0.85 and 0.72). Causes not yet looked into: round 27.

**Twenty-seventh round: grids that keep their own header, letter-spaced CJK titles; then golden_v28.** Fixed on golden_v27 (now a development set) and checked on all twenty-seven sets:
- a table drawn as a full grid whose first row is already a bold header takes no header rows from above (an invoice's key/value panel and address over its items grid, m01; k16's key/value line) -- stopping growth for every grid cost six sets in round 26, the bold header is the narrower sign;
- a CJK title letter-spaced wide ("御 見 積 書"): single characters of a script without spaces, three or more, each set apart by one space, are one word.

Tried and withdrawn: a wider row tolerance for Arabic glyphs, so that "لاً" (a ligature carrying its vowel marks, half an em off the line) joins "أولاً" -- it split m04's headings further and moved twelve sets both ways.

On the development sets, against round 26 frozen: tables v26 0.82 -> 0.85, v27 0.75 -> 0.76; headings v27 0.85 -> 0.89, v21 0.93 -> 0.95, v24 0.93 -> 0.95; nothing fell. A short round: the remaining golden_v27 misses each need a design of their own -- a key/value panel of two rows (m21; the aligned finder wants three), a definitions table whose definitions are real prose (m21), Arabic marks off the line (m04), m01's items grid still taking a row of its panel. Guard 232 assertions under Ring++.

golden_v28: 24 realistic documents in 18 languages besides English (Arabic, Hebrew and Persian right to left, Japanese, Chinese, Korean, Hindi, Thai, Vietnamese among them), 13 of 2-3 pages, three tables across pages, one landscape page, code in one document only (n07), by a twenty-eighth independent agent who saw no reader, no output and no earlier set; no one has looked at the pages (unperceived); reader frozen at 1719303b8; both readers ran once:

| golden_v28, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.99** | **1.00** | **0.98** | **0.76** | **0.88** | **0.79** | **0.67** | **0.87** |
| Docling 2.141 | 0.81 | 0.99 | 0.81 | 0.67 | 0.52 | 0.72 | 0.00 | 0.78 |

Time for the 24 documents: native 0.09 s, Docling 170 s. The native reader leads on all eight measures, the sixth set where it does; text and headings are its highest on any new set. Where Docling does better, document by document: tables on six (n06, a bank statement across pages, 0.10 against 0.78; n16 0.47 against 0.96; n09 0.50 against 0.94; n02 0.27 against 0.73), headings on three, furniture on three (n17 0.25 against 1.00), lists on two (n09). Causes not yet looked into: round 28.

**Twenty-eighth round: grids ruled between columns only, section rows with no rule, letterhead addresses; then golden_v29.** Fixed on golden_v28 (now a development set) and checked on all twenty-eight sets:
- a grid ruled between its columns but not between its items (a quotation: a rule under the header and rules round the totals) held its whole body in one grid row, each column one cell ("1 2 3 4 5"): a grid row far taller than the grid's others, with three baselines or more each filling most columns, is a row per baseline. Measured on the way: splitting on baselines touching two columns took wrapped cells for rows on eighteen sets; full rows only still cost ten; the row-height sign cost none;
- a section row drawn with no rule under it shares its ladder band with the row below: a lone bold label over a line of cells is split from it;
- a letterhead's address under its name, beside the title's subtitle, is letterhead (paragraphs only: the wider reach took sidebar headings).

Tried and withdrawn: splitting a four-column key/value table into two panels at a wide gutter (n06) -- it never fired on n06 and cost tables on six sets (v4 1.00 -> 0.875).

On the development sets, against round 27 frozen: tables v28 0.76 -> 0.79, v22 0.91 -> 0.94, v5 0.84 -> 0.85; furniture v28 0.79 -> 0.82, v13 0.80 -> 0.82, v7 0.75 -> 0.76. Costs: heading precision v24 0.809 -> 0.796, v8 -0.005, tables v24 -0.002. Not reached: n06 (two key/value panels side by side read as one table; its movements table loses the header and merges debit and credit), n16 (its ladder's bands hold two data rows each), n09 (a Chinese specification sheet). Guard 235 assertions under Ring++.

golden_v29: 24 realistic documents in 20 languages besides English (Arabic, Hebrew and Persian right to left, Japanese, Chinese, Korean, Hindi, Thai, Vietnamese, and Amharic in the Ethiopic script for the first time), 14 of 2-3 pages, running headers drawn by CSS page-margin boxes, code in three documents, by a twenty-ninth independent agent who saw no reader, no output and no earlier set; no one has looked at the pages (unperceived); reader frozen at ffa2446d8; both readers ran once:

| golden_v29, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.97** | 1.00 | **0.92** | **0.77** | **0.89** | **0.81** | **0.50** | **0.81** |
| Docling 2.141 | 0.81 | 1.00 | 0.76 | 0.72 | 0.58 | 0.77 | 0.00 | 0.67 |

Time for the 24 documents: native 0.08 s, Docling 84 s. The native reader leads on seven measures and ties on order. Where Docling does better, document by document: tables on six (p09 0.24 against 0.94, p24 0.17 against 0.83, p19 0.12 against 0.80, p04 0.63 against 0.95), lists on two (p23, Amharic, 0.33 against 1.00; p07, Chinese, 0.43 against 1.00), furniture on three, text on one. Code is low for the native reader too (0.50: three blocks in three documents). Causes not yet looked into: round 29.

**Twenty-ninth round: row-group labels, grids without outer rules, section rows in two columns, more list markers; then golden_v30.** Fixed on golden_v29 (now a development set) and checked on all twenty-nine sets:
- a first column of row-group labels, each set centred beside the rows it spans ("Mlimani" beside its three stations): the groups tile the body from its first row, so the size of each follows from where its label stands, and the label repeats in each row; a last row holding a label and a figure with empty cells between is a total, its label spanning them. The ladder gives way to such a table when a rule walls the label column off down its whole height; without that wall the exception took a left panel for a label column (n06);
- a grid ruled between its columns but with no outer vertical rules (a statement whose rows have only bottom borders): the first and last columns lie outside the outermost verticals, bounded by the horizontal rules' ends;
- a bold label alone in a band is a section row in a two-column table too (it needed three columns), repeated across both: a spec sheet's "Algemeen" / "Prestaties";
- a ladder holding wrapped cells (two lines in every cell of a band) is clean when its lines sit closer than 0.85 of a one-line band and padding stands round the band once; this stopped such a ladder from being dissolved for a table read line by line. Measured on the way: the pitch alone took three merged-row bands for wrapped cells (v10 q11, 0.80 -> 0.11); the padding test took them back;
- a wrapped line at a leading up to 1.5 (it was 1.35) stays in a row of an unruled table when it continues the row's LAST cell and fewer than two rules run down the rows: a 10 pt Calibri table sets 13.8 pt; looser leading in the middle columns took a statement apart (g03), and an eagerly read unruled table took a ruled ladder from its own rules (p22);
- Ethiopic digits and syllables are list markers ("፩." and "ሀ)"), and a number and a full stop set against Chinese text with no space ("1.本报告");
- a bold title of two lines, larger than the body, is a heading (it needed one line).

Tried and withdrawn: the same 1.5 leading for a row of several cells under its row (k19 lost the text of three rows to its tall-cell merge), and the 1.5 leading for every continuation line.

On the development sets, against round 28 frozen: tables v29 0.77 -> 0.87, v28 0.79 -> 0.82, v27 0.755 -> 0.766; lists v29 0.89 -> 0.95, v28 0.88 -> 0.90, v15 0.92 -> 0.94, v13 0.84 -> 0.86; headings v29 0.92 -> 0.97, v28 0.98 -> 0.99, v23 0.97 -> 0.98, v5 0.86 -> 0.87. Costs: heading precision v18 -0.006, v21 -0.004, v25 -0.004, v26 -0.004, v27 -0.004. Not reached: p03 (an Arabic mark off the line splits "أولاً" into three fragments), p06, p13, p01 (tables), p12 (furniture), p22 (code). Guard 246 assertions under Ring++.

golden_v30: 24 realistic documents in 19 languages (English in six; Arabic, Hebrew and Persian right to left; Japanese, Chinese, Korean, Hindi, Thai, Georgian, Vietnamese and others), 19 of 2-3 pages, running headers drawn by CSS page-margin boxes in five, code in two, by a thirtieth independent agent who saw no reader, no output and no earlier set and ran no extractor or rasterizer (its expectations come from the HTML, so the page breaks of its five flowing documents and the soft hyphens of r02 are unchecked in the PDFs); no one has looked at the pages (unperceived); reader frozen at 9494d729e; both readers ran once:

| golden_v30, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.96** | **1.00** | **0.98** | **0.94** | **0.85** | 0.89 | **0.83** | **0.88** |
| Docling 2.141 | 0.73 | 0.98 | 0.72 | 0.75 | 0.32 | 0.89 | 0.17 | 0.66 |

Time for the 24 documents: native 0.06 s, Docling 90 s. The native reader leads on six measures and on heading precision; furniture is level (0.892 against 0.893). Where Docling does better, document by document: tables on two (r04 0.20 against 0.60; r16 0.72 against 0.93), lists on three (r10 0.46 against 0.69; r14 0.12 against 0.25; r16 0.40 against 0.60), furniture on four (r05, r13, r20, r22), text on three (r08, r10, r22). Causes not yet looked into: round 30.


**Thirtieth round: right-to-left markers, flush-wrapped items, three-rule tables, justified lines; then golden_v31.** Fixed on golden_v30 (now a development set) and checked on all thirty sets:
- a right-to-left item's marker (digits and a stop, or brackets, three glyphs or fewer) set apart at the row's right end is part of the line, so "١." and "[۲]" head their items, nested levels with them; Persian reference numbers in square brackets and the three-letter marker "الف)" are markers;
- a line wrapped flush with its marker (an item set "inside") joins the item while the item has not ended and the line goes on in lower case;
- Georgian letters are list markers; a justified line, four or more equal word gaps wider than a column cut between real words and the line spanning 0.7 of the page, is one line, not a row of columns (a narrower row cannot be told from columns by its gaps: a three-column newsletter's gutter is 1.2 em);
- a table of a bold header and two ruled rows (three rules) is a ladder, and joins the next page's rows; an organisation's letterhead is found by five digits in any script;
- a title repeated as a small running header on the other pages, set bold, centred and 1.8 times the body, stays a title (a masthead at a side, or in the page's header band, stays furniture: four sets lost furniture before the rule was narrowed); a letter-spaced CJK title keeps its spacing even when one word stays whole.

Not fixed, and why: r22's sidebar label sits between two lines of the paragraph beside it (the reading order interleaves them); r20's menu rows carry a smaller description line under each dish (a different size breaks the run); r16's key/value panel has rows far apart because its values wrap. The measure cannot count r13, r15, r12 and r01 furniture (the organisation's name is inside a body sentence), and r08's title is also its running header (counted as furniture or as heading, never both).

On the development sets, against round 29 frozen: lists v30 0.85 -> 0.98, v29 0.95 -> 0.98, v14 0.81 -> 0.87, v26 0.79 -> 0.83, v27 0.87 -> 0.90, v25 0.83 -> 0.87, v28 0.90 -> 0.92; tables v30 0.94 -> 0.97, v6 0.74 -> 0.76; text v30 0.96 -> 0.99; headings v30 0.98 -> 1.00; furniture v18 0.92 -> 0.95; heading precision v30 0.878 -> 0.895. No set lost on any measure. Guard 256 assertions under Ring++.

golden_v31: 24 realistic documents in 17 languages (English in eight; Arabic, Hebrew and Persian right to left; Chinese, Japanese, Korean, Hindi, Thai, Greek, Polish, Turkish and others), 19 of 2-3 pages, code in four, by a thirty-first independent agent who saw no reader, no output and no earlier set and ran no extractor or rasterizer (layout checked by DOM geometry only; the running header and page-number lines of s21 assume what the margin boxes printed); no one has looked at the pages (unperceived); reader frozen at d46a1329b; both readers ran once:

| golden_v31, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.98** | 1.00 | **1.00** | **0.88** | **0.82** | **0.89** | **0.92** | **0.94** |
| Docling 2.141 | 0.75 | 1.00 | 0.85 | 0.71 | 0.40 | 0.74 | 0.33 | 0.77 |

Time for the 24 documents: native 0.07 s, Docling 114 s. The native reader leads on six measures and on heading precision, and ties on order. Where Docling does better, document by document: tables on four (s12 0.48 against 0.99, s23 0.28 against 0.98, s24 0.47 against 0.68, s04 0.81 against 0.93), lists on one (s05, Chinese, 0.00 against 0.73), furniture on one (s08). Causes not yet looked into: round 31.


**Thirty-first round: markers kept with their text, a table beside a numbered list, diamond bullets, wrapped headers; then golden_v32.** Fixed on golden_v31 (now a development set) and checked on all thirty-one sets:
- a marker in the full-width conventions ("（一）", "1．", "①") or an ordinal ("1°") set apart from its text by a hanging indent stays on the line with the text it heads (it was cut at the gap and read as a paragraph of its own); an ASCII digit before a full-width stop is a marker; Devanagari letters are list markers;
- a list line wrapped to the LEFT of its marker (the text hangs outside it) joins the item while the item goes on in lower case;
- a rectangle turned by the page matrix (a diamond bullet, a square turned 45 degrees) lost two of its corners in the bounding box, so its width read zero and it was never a bullet: all four corners count now;
- a numbered list of phrases beside a table with no rule between them (a recipe's steps beside its ingredients): the list's left edge is the boundary, over the rows they share, when the right side holds nothing but the list, no line crosses the boundary and the left side has three rows of two cells or more. Three broader forms cost k13, h14 and r22 (a table whose right-hand columns stood where a list stood, a two-column page, a list whose continuation lines remained);
- a ruled grid that opens with a section row ("Kitchen" in every cell) takes the header above it (it counted as a header of its own);
- a header whose cells wrap onto a second line that opens with a bracket ("SGK işçi payı" over "(%14)") is one row (lower-case continuations took group labels for wrapped cells: a03);
- a one-line address with an e-mail or a web address under the letterhead's name is letterhead.

Not fixed, and why: s06 and s05 expect a space after a full-width marker the PDF does not draw (the authors disagree: v29 expected none); s21's totals row sets its right-aligned figures one column left of their header, so the two halves of its table do not join across the page; s09 sets "aa)" and "bb)" inline in a running sentence; s05's "1、" items are inline in a paragraph.

On the development sets, against round 30 frozen: lists v31 0.82 -> 0.93, v14 0.87 -> 0.89, v20 0.85 -> 0.87, v26 0.83 -> 0.85, v27 0.90 -> 0.92, v24 0.92 -> 0.93; tables v31 0.88 -> 0.95, v17 0.81 -> 0.86, v26 0.85 -> 0.87, v28 0.79 -> 0.81; furniture v31 0.89 -> 0.90, v24 0.80 -> 0.82, v20 0.80 -> 0.81. No set lost on any measure. Guard 266 assertions under Ring++.

golden_v32: 24 realistic documents in 16 languages (English in nine; Arabic, Hebrew and Persian right to left; Japanese, Chinese, Korean, Hindi, Thai, Vietnamese and others), 22 of 2-3 pages, code in two, by a thirty-second independent agent who saw no reader, no output and no earlier set and ran no extractor or rasterizer (layout checked by DOM geometry only; t17 and t24 place a fixed header and footer in the page margins by negative offsets, unseen); no one has looked at the pages (unperceived); reader frozen at 15651416b; both readers ran once:

| golden_v32, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.98** | **1.00** | **0.98** | **0.83** | **0.91** | **0.80** | **0.88** | **0.87** |
| Docling 2.141 | 0.83 | 0.99 | 0.89 | 0.71 | 0.45 | 0.78 | 0.00 | 0.83 |

Time for the 24 documents: native 0.08 s, Docling 195 s. The native reader leads on all eight measures, the seventh set where it does; furniture is a lead of 0.02. Where Docling does better, document by document: tables on five (t15 0.00 against 1.00, t20 0.00 against 1.00, t13 0.29 against 0.78, t09 0.67 against 1.00, t18 0.81 against 1.00), lists on one (t04 0.58 against 1.00), furniture on four (t05, t08, t11, t13), text on one (t05), headings on one (t15). Causes not yet looked into: round 32.


**Thirty-second round: tables in the columns of a two-column page, a panel above a header; then golden_v33.** Fixed on golden_v32 (now a development set) and checked on all thirty-two sets:
- a page set in two text columns (each column eight lines or more of five words or more, their lines overlapping over 45 per cent of their length, the gutter between them empty of any line down the stretch round them) reads the tables in each column on its own, over the rows from the nearest line crossing the gutter above to the nearest below: a journal's Table 1 in the left column and Table 2 in the right were read as one seven-column table. When the two halves come out with the same top, the same foot and as many rows, the gutter fell between two columns of ONE table (g16: a calendar across a two-column page) and the text is read again as one;
- a key/value panel (three rows of two cells, then a row of four cells or more set 1.3 pitches further off) ends where that row begins -- it was the header of the table under it (t13). The pitch of the panel's rows must be at least 1.2 times its type: a wrapped header's lines (6.8 pt apart in t15) are not a panel;
- a kana letter and a full-width stop ("ア．") is a list marker, and a script written without spaces counts a word as three characters when a list of markers is told from a two-column table.

Tried and withdrawn: a looser leading (1.55) for a wrapped half of a cell wherever the rows around it stand two pitches apart, and five words for the cells of a table with a bold header (t20's classifieds): each took cells from g03, k19, k08, d11 and b20, and each was not worth them. A column no row writes in was dropped for a while: it changed y08's table for the worse and fixed nothing. Not reached: t20's classifieds table (two-line cells at 1.5 leading, five-word cells), t09's zebra table of three rows, t18, t05's and t08's furniture (the organisation's name is inside a body sentence).

On the development sets, against round 31 frozen: tables v32 0.83 -> 0.90, v6 0.76 -> 0.80, v21 0.95 -> 0.95; lists v32 0.91 -> 0.92; text v23 0.98 -> 0.99; headings v13 0.93 -> 0.94. No set lost on any measure. Guard 272 assertions under Ring++.

golden_v33: 24 realistic documents in 18 languages (English in six; Arabic, Hebrew and Persian right to left, and an Arabic invoice; Japanese, Chinese, Korean, Hindi, Bengali, Thai, Georgian and others), 14 of 2-3 pages, code in two, by a thirty-third independent agent who saw no reader, no output and no earlier set and ran no extractor or rasterizer (layout checked by DOM geometry and screenshots of its own HTML; pages are explicit A4 boxes with the furniture in the body, tables continued across pages split by hand). One disclosure: the author printed the first 300 bytes of an earlier set's generator file by mistake (an invoice header) and used nothing from it. No one has looked at the pages (unperceived); reader frozen at 88bf78bcf; both readers ran once:

| golden_v33, realistic | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.98** | 1.00 | **0.99** | **0.87** | **0.90** | **0.81** | **1.00** | **0.84** |
| Docling 2.141 | 0.74 | 1.00 | 0.81 | 0.67 | 0.45 | 0.79 | 0.25 | 0.68 |

Time for the 24 documents: native 0.09 s, Docling 164 s. The native reader leads on seven measures and ties on order. Where Docling does better, document by document: tables on four (u15 0.27 against 0.73, u13 0.50 against 0.80, u20 0.60 against 0.70, u14 0.40 against 0.47), furniture on six (u03, u05, u10, u11, u12, u16), headings on two (u14, u21). Causes not yet looked into: round 33.


**The first set from producers other than Chrome (2026-10-30): golden_v34.** Every earlier set was made by Chrome, so none could say whether the reader depends on how Chrome writes a PDF. golden_v34 is 24 documents by a thirty-fourth independent agent (no reader, no output, no earlier set, no extractor or renderer; PyMuPDF used to write only; nobody has looked at a page, so it is unperceived), from four producers: ReportLab 5.0.1 Platypus (9) and its low-level canvas (4), PyMuPDF 1.28.2 (Story/HTML and insert_text, 5), matplotlib 3.11.2 (Type 42 and Type 3 fonts, 2) and Microsoft Print to PDF driven from PowerShell (GDI, 4). Ten are English, thirteen are in other languages (three right to left: Arabic and Hebrew by MuPDF, an Arabic invoice by GDI; Japanese, Chinese and Korean in TrueType); several English, German and Italian documents use the standard-14 fonts, not embedded; 19 have 2 or 3 pages. Reader frozen at 88bf78bcf, both readers ran once:

| golden_v34, other producers | text | order | headings | tables | lists | furniture | code | heading precision |
|---|---|---|---|---|---|---|---|---|
| Softanza native (Ring++) | **0.98** | 0.99 | **0.95** | **0.90** | **0.78** | **0.82** | 0.83 | **0.92** |
| Docling 2.141 | 0.85 | 1.00 | 0.87 | 0.73 | 0.22 | 0.81 | 0.83 | 0.81 |

Time for the 24 documents: native 0.11 s, Docling 215 s. **The reader does not depend on Chrome.** Its text, headings and tables are within a few points of its Chrome numbers (golden_v29-v33: text 0.97-0.98, headings 0.92-1.00, tables 0.77-0.94), and it still leads Docling on six measures, ties on code and trails on order by 0.01. The weak measure is lists (0.78, against 0.82-0.91 on the Chrome sets): nine of the twenty-four documents score below 0.7 on lists, among them x01, x04 and x12 (0.00 each: bullets and check boxes drawn as graphics, which carry no marker text), and furniture (0.82; x11 0.17, x12 0.44, x24 0.50). Where Docling does better: tables on x12 (0.50 against 1.00), x14 (0.52 against 1.00) and x20 (0.63 against 0.95), furniture on x16, x17, x18 and x23, text and headings on x17 and headings on x22 (0.25 against 1.00). Causes not yet looked into: round 33 starts here.

**Perceived (2026-10-24):** the author looked through every rendered page of golden_v9 to golden_v13 -- the sets whose own authors could not look at them -- and judged them: "they look great". Those five sets are no longer unperceived; the sets before them were generated the same way and are not covered by this look.

**Perceived (2026-10-29):** the author looked at the generated documents of golden_v14 to golden_v22 and judged them: "they are ok". Those nine sets are no longer unperceived.

**Not measured**: Granite-Docling-258M (not downloaded), the GPU, scanned golden pages with an expected text, PDFs from producers other than Chrome (both golden sets are Chrome-made and tagged; the native reader does not read the tags).

---

## 7. Verified vs not verified

**Verified live by the author of this memo (2026-10-21):** Granite-Docling-258M is Apache-2.0, `idefics3`, 257,517,120 BF16 parameters; `docling-layout-heron` is Apache-2.0, `rt_detr_v2`, 42,889,979 parameters; Indra's weights are a modified OpenRAIL-M with a $20M funding/revenue cap and a no-compete clause, code Apache-2.0; Qwen3-4B-Instruct-2507 is Apache-2.0, `qwen3`, 4.02B parameters.
**Read in the tree:** the engine's lack of PDF/OCR/OOXML code, the token-id-only decoder entry, the C++ static-initialiser NOTICE, the one model slot.
**From the research pass, not re-verified:** TableFormer's internal wiring (the `tablemodel04_rs` source was not read); the published pages/s figures; the official Granite-Docling GGUF file sizes; whether Granite uses extra scale multipliers (the config says `llama`); RapidOCR model sizes and which Paddle models exist for Arabic/French; ONNX operator coverage of the layout model.
**Not tools-checkable here:** any claim of the form "faster than" on this machine. No time was taken on this machine for any document stage.
